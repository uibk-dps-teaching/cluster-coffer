#include <Adafruit_NeoPixel.h>
#include <Arduino.h>

static constexpr auto LED_PIN = 6;
static constexpr auto LED_COUNT = 98;

// Argument 1 = Number of pixels in NeoPixel strip
// Argument 2 = Arduino pin number (most are valid)
// Argument 3 = Pixel type flags, add together as needed:
//   NEO_KHZ800  800 KHz bitstream (most NeoPixel products w/WS2812 LEDs)
//   NEO_KHZ400  400 KHz (classic 'v1' (not v2) FLORA pixels, WS2811 drivers)
//   NEO_GRB     Pixels are wired for GRB bitstream (most NeoPixel products)
//   NEO_RGB     Pixels are wired for RGB bitstream (v1 FLORA pixels, not v2)
//   NEO_RGBW    Pixels are wired for RGBW bitstream (NeoPixel RGBW products)
Adafruit_NeoPixel g_strip(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);

////////////////////////////////////////////////////////////////////////// - Helper

struct Color {
	uint32_t val;
	uint8_t &r = reinterpret_cast<uint8_t *>(&val)[0];
	uint8_t &g = reinterpret_cast<uint8_t *>(&val)[1];
	uint8_t &b = reinterpret_cast<uint8_t *>(&val)[2];
	uint8_t &a = reinterpret_cast<uint8_t *>(&val)[3];

	Color() : val(0) {}
	Color(const uint32_t &colVal) : val(colVal) {}

	Color(const Color &other) : val(other.val) {}
	Color(Color &&other) : val(other.val) {}

	Color &operator=(const Color &other)
	{
		val = other.val;
		return *this;
	}
	Color &operator=(Color &&other)
	{
		val = other.val;
		return *this;
	}

	Color &operator*=(const float &scalar)
	{
		uint8_t *resVal = reinterpret_cast<uint8_t *>(&val);

		for (uint8_t i = 0; i < sizeof(uint32_t); ++i) {
			auto scaledVal = round(resVal[i] * scalar);
			if (scaledVal < 0)
				scaledVal = 0;
			if (scaledVal > 255)
				scaledVal = 255;
			resVal[i] = static_cast<uint8_t>(scaledVal);
		}

		return *this;
	}

	Color interpolate(const Color &rhs, float percent) const
	{
		if (percent < 0)
			percent = 0;
		if (percent > 1)
			percent = 1;

		Color res;

		uint8_t *resVal = reinterpret_cast<uint8_t *>(&res.val);
		const uint8_t *lhsVal = reinterpret_cast<const uint8_t *>(&val);
		const uint8_t *rhsVal = reinterpret_cast<const uint8_t *>(&rhs.val);

		for (uint8_t i = 0; i < sizeof(uint32_t); ++i) {
			auto interpolated = lhsVal[i] + percent * rhsVal[i] - percent * lhsVal[i];
			if (interpolated < 0)
				interpolated = 0;
			if (interpolated > 255)
				interpolated = 255;
			resVal[i] = static_cast<uint8_t>(round(interpolated));
		}

		return res;
	}
};

template <typename InType, typename OutType>
OutType map(const InType &val, const InType &inRangeMin, const InType &inRangeMax, const OutType &outRangeMin,
            const OutType &outRangeMax)
{
	return (val - inRangeMin) * (outRangeMax - outRangeMin) / (inRangeMax - inRangeMin) + outRangeMin;
}

////////////////////////////////////////////////////////////////////////// - Pixel buffer

static constexpr auto NUM_SEGMENTS = 4;
static constexpr auto NUM_SUBSEGMENTS = 9;
static constexpr auto RESOLUTION = NUM_SEGMENTS * NUM_SUBSEGMENTS;
static_assert(RESOLUTION >= 16, "Boot effect reuses pixel buffer and therefore needs at least resolution of 16!");
static constexpr auto WAVE_LENGTH = LED_COUNT / 10;

class PixelBuffer {
  public:
	PixelBuffer() = default;

	PixelBuffer(PixelBuffer &) = delete;
	PixelBuffer(PixelBuffer &&) = delete;
	PixelBuffer &operator=(PixelBuffer &) = delete;
	PixelBuffer &operator=(PixelBuffer &&) = delete;

	// Subscript operator shifted by offset
	Color &operator[](const int &idx)
	{
		return sm_pixels[(idx + sm_shiftOffset) % RESOLUTION];
	}

	// Offset independent subscript
	static Color &at(const int &idx)
	{
		return sm_pixels[idx];
	}

	static void offset(uint8_t val)
	{
		sm_shiftOffset = val % RESOLUTION;
	}

	static void shift(uint8_t val)
	{
		sm_shiftOffset = (sm_shiftOffset + val) % RESOLUTION;
	}

  private:
	static Color sm_pixels[RESOLUTION];
	static uint8_t sm_shiftOffset;
};

Color PixelBuffer::sm_pixels[RESOLUTION];
uint8_t PixelBuffer::sm_shiftOffset = 0;

static PixelBuffer g_pixels;

////////////////////////////////////////////////////////////////////////// - Serial protocol

// clang-format off
enum class ModeBits {
	NONE         = 0b0000'0000,
	BOOT         = 0b0000'0001,
	LOAD         = 0b0000'0010,
	MAGIC_NUMBER = 0b1111'0000,
};
// clang-format on

static bool receiveMsg(uint8_t buffer[16], ModeBits &modeStatus)
{
	static uint8_t s_rcvBuffer[16];
	static uint8_t s_rcvIdx = 0;
	static uint8_t s_rcvdMode = static_cast<uint8_t>(ModeBits::NONE);

	while (Serial.available() && s_rcvIdx < 16) {
		uint8_t rcvd = Serial.read();

		if ((rcvd & static_cast<uint8_t>(ModeBits::MAGIC_NUMBER)) == static_cast<uint8_t>(ModeBits::MAGIC_NUMBER)) {
			s_rcvdMode = rcvd & ~static_cast<uint8_t>(ModeBits::MAGIC_NUMBER);
			s_rcvIdx = 0;
		} else
			s_rcvBuffer[s_rcvIdx++] = rcvd;
	}

	if (s_rcvIdx >= 16) {
		s_rcvIdx = 0;
		modeStatus = static_cast<ModeBits>(s_rcvdMode);
		memcpy(buffer, s_rcvBuffer, 16);
		return true;
	}

	return false;
}

////////////////////////////////////////////////////////////////////////// - Boot effect

static void updateBootEffect(float boot[16])
{
	const Color unbootedColor(0x00'00'00);
	const Color bootingColor(0xFF'00'00);
	const Color bootedColor(0x00'FF'00);

	for (uint8_t i = 0; i < 16; ++i) {
		if (boot[i] == 0)
			g_pixels.at(i) = unbootedColor;
		else if (boot[i] < 0.5f)
			g_pixels.at(i) = unbootedColor.interpolate(bootingColor, boot[i] * 2);
		else
			g_pixels.at(i) = bootingColor.interpolate(bootedColor, 2 * (boot[i] - 0.5f));

		if (boot[i] > 0 && boot[i] < 1)
			boot[i] += 0.01f;
	}
}

static void mapBootBufferToPixels()
{
	for (uint16_t i = 0; i < g_strip.numPixels(); ++i) {
		const auto colIdx = map(i, 0.0f, g_strip.numPixels(), 0, 16);
		g_strip.setPixelColor(i, g_pixels.at(colIdx).val);
	}
}

static void regulateBrightness()
{
	constexpr auto NORMAL_BRIGHTNESS = 0.2f;

	for (uint16_t i = 0; i < g_strip.numPixels(); ++i) {
		Color curPixel(g_strip.getPixelColor(i));
		curPixel *= NORMAL_BRIGHTNESS;
		g_strip.setPixelColor(i, curPixel.val);
	}
}

////////////////////////////////////////////////////////////////////////// - Load effect

static void calcAggregateLoad(const uint8_t load[16], uint8_t aggregate[4])
{
	uint16_t sum = 0;
	sum += load[8];
	sum += load[9];
	sum += load[12];
	sum += load[13];
	aggregate[0] = sum / 4;

	sum = 0;
	sum += load[10];
	sum += load[11];
	sum += load[14];
	sum += load[15];
	aggregate[1] = sum / 4;

	sum = 0;
	sum += load[2];
	sum += load[3];
	sum += load[6];
	sum += load[7];
	aggregate[2] = sum / 4;

	sum = 0;
	sum += load[0];
	sum += load[1];
	sum += load[4];
	sum += load[5];
	aggregate[3] = sum / 4;
}

static uint8_t calcTotalLoad(const uint8_t load[16])
{
	uint16_t sum = 0;
	for (uint8_t i = 0; i < 16; ++i)
		sum += load[i];

	sum /= 16;

	if (sum > 100)
		sum = 100;

	return static_cast<uint8_t>(sum);
}

static Color mapLoadToColor(uint8_t load)
{
	const Color coldColor(0x00'FF'00);
	const Color hotColor(0xFF'00'00);

	return coldColor.interpolate(hotColor, load / 100.0f);
}

static void updateLoadEffect(uint8_t load[16])
{
	uint8_t aggregateLoad[4];
	calcAggregateLoad(load, aggregateLoad);

	for (uint8_t i = 0; i < RESOLUTION; ++i) {
		const auto segIdx = (i * NUM_SEGMENTS) / RESOLUTION;
		const auto subsegIdx = i % NUM_SUBSEGMENTS;
		const auto segCol = mapLoadToColor(aggregateLoad[segIdx]);

		if (subsegIdx == 0) {
			const auto prevSegIdx = (segIdx == 0) ? (NUM_SEGMENTS - 1) : (segIdx - 1);
			const auto prevSegCol = mapLoadToColor(aggregateLoad[prevSegIdx]);
			g_pixels.at(i) = prevSegCol.interpolate(segCol, 0.5f);
		} else if (subsegIdx == NUM_SUBSEGMENTS - 1) {
			const auto nextSegIdx = (segIdx + 1) % NUM_SEGMENTS;
			const auto nextSegCol = mapLoadToColor(aggregateLoad[nextSegIdx]);
			g_pixels.at(i) = segCol.interpolate(nextSegCol, 0.5f);
		} else
			g_pixels.at(i) = mapLoadToColor(aggregateLoad[segIdx]);
	}
}

static void interpolatePixels()
{
	for (uint16_t i = 0; i < g_strip.numPixels(); ++i) {
		const auto pixelPos = map<float, float>(i, 0.0f, g_strip.numPixels() - 1, 0.0f, RESOLUTION - 1);

		const auto curPixelIdx = static_cast<uint16_t>(floor(pixelPos));
		const auto nextPixelIdx = static_cast<uint16_t>(ceil(pixelPos));

		const auto curPixel = g_pixels[curPixelIdx];

		if (static_cast<float>(curPixelIdx) == pixelPos)
			g_strip.setPixelColor(i, curPixel.val);
		else {
			const auto weight = pixelPos - curPixelIdx;
			const auto nextPixel = g_pixels[nextPixelIdx];

			const auto slopeR = (static_cast<float>(nextPixel.r) - curPixel.r);
			const auto slopeG = (static_cast<float>(nextPixel.g) - curPixel.g);
			const auto slopeB = (static_cast<float>(nextPixel.b) - curPixel.b);

			Color interpolated;
			interpolated.r = curPixel.r + slopeR * weight;
			interpolated.g = curPixel.g + slopeG * weight;
			interpolated.b = curPixel.b + slopeB * weight;

			g_strip.setPixelColor(i, interpolated.val);
		}
	}
}

static void imposeWave(const float &pos)
{
	constexpr auto NORMAL_BRIGHTNESS = 0.1f;
	constexpr auto WAVE_BRIGHTNESS = 1.0f;

	for (uint16_t i = 0; i < g_strip.numPixels(); ++i) {
		Color curPixel(g_strip.getPixelColor(i));

		auto waveDist = (i < pos) ? (pos - i) : (i - pos);
		auto wrappedWaveDist = waveDist;

		if (pos + WAVE_LENGTH / 2.0f > g_strip.numPixels()) {
			const auto wrappedPos = (pos - g_strip.numPixels());
			wrappedWaveDist = i - wrappedPos;
		} else if (pos - WAVE_LENGTH / 2.0f < 0) {
			const auto wrappedPos = (pos + g_strip.numPixels());
			wrappedWaveDist = wrappedPos - i;
		}

		waveDist = (wrappedWaveDist < waveDist) ? wrappedWaveDist : waveDist;

		if (waveDist > WAVE_LENGTH / 2.0f)
			curPixel *= NORMAL_BRIGHTNESS;
		else {
			const auto intensity = 1.0f - waveDist / (WAVE_LENGTH / 2.0f);
			auto waveBrightness = WAVE_BRIGHTNESS * intensity;
			if (waveBrightness < NORMAL_BRIGHTNESS)
				waveBrightness = NORMAL_BRIGHTNESS;
			curPixel *= waveBrightness;
		}

		g_strip.setPixelColor(i, curPixel.val);
	}
}

////////////////////////////////////////////////////////////////////////// - Main (setup + loop)

static constexpr auto STATUS_LED_PIN = 13;
static constexpr auto STATUS_LED_FLASH_DELAY = 100;

void setup()
{
	// The Neopixel driver disables all interrupts, so Serial cannot receive during strip.show()
	// Setting the baud rate slow enough fixes Serial inputs being dropped during strip.show()
	Serial.begin(2400);

	g_strip.begin();
	g_strip.show();             // Turn off all LEDs on startup
	g_strip.setBrightness(255); // Set brightness to maximum, because final brightness is set before sending

	g_pixels.offset(4); // Offset first pixel

	pinMode(STATUS_LED_PIN, OUTPUT); // Set on-board LED as output
}

void loop()
{
	static uint8_t s_rcvBuffer[16]; // Receive buffer, only changed when message is received successfully
	static float s_bootStatus[] = {
	    0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f,  // Booting animation for each node
	    0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f}; // 0 = off, ]0, 0.5[ = fade red, [0.5, 1] = fade green

	static auto s_modeState = ModeBits::NONE;
	static auto s_statusLedFlashStart = millis();

	if (receiveMsg(s_rcvBuffer, s_modeState)) {
		digitalWrite(STATUS_LED_PIN, HIGH); // Show message was received successfully
		s_statusLedFlashStart = millis();

		if (s_modeState == ModeBits::BOOT) {
			for (uint8_t i = 0; i < 16; ++i) {
				if (!s_rcvBuffer[i])
					s_bootStatus[i] = 0.0f; // When booting msg received, set all unbooted nodes to 0
				else if (s_bootStatus[i] == 0.0f)
					s_bootStatus[i] = 0.01f; // and all nodes that should boot and have not started booting to 0.01
			}
		}
	}

	if (millis() - s_statusLedFlashStart > STATUS_LED_FLASH_DELAY)
		digitalWrite(STATUS_LED_PIN, LOW); // Flash status LED for STATUS_LED_FLASH_DELAY

	static float s_wavePos = 0;
	if (s_modeState == ModeBits::LOAD)
		s_wavePos += 0.5f + 1.5f * (calcTotalLoad(s_rcvBuffer) / 100.0f); // Load dependent wave speed
	s_wavePos = (s_wavePos > g_strip.numPixels()) ? (s_wavePos - g_strip.numPixels()) : s_wavePos;

	if (s_modeState == ModeBits::BOOT) {
		updateBootEffect(s_bootStatus);
		mapBootBufferToPixels();
		regulateBrightness();
	} else if (s_modeState == ModeBits::LOAD) {
		updateLoadEffect(s_rcvBuffer);
		interpolatePixels();
		imposeWave(s_wavePos); // Automatically regulates brightness
	}

	// Sends data to all LEDs and disables all interrupts
	g_strip.show();
}
