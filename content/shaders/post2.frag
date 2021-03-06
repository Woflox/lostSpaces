#version 130

uniform sampler2D sceneTex;
uniform float t;
uniform float aspectRatio;
uniform float blur;
uniform float invCorrectedGamma;

const float pi2 = 3.1415926536 * 2.0;
const int numSamples = 6;
const float contrastBoost = 2.0;
const float gamma = 2.2;

in vec2 texCoords;

out vec4 color;

float uniformRandom(float x)
{
  x = mod(x, 13.0) * mod(x, 123.0);
	return fract(x * 100.0);
}

void main (void)
{
  color = vec4(0.0, 0.0, 0.0, 1.0);

  for (int i = 0; i < numSamples; i++)
  {
    float noise1 = uniformRandom(texCoords.x * texCoords.y * (t + float(i)) * 1000.0);
    float noise2 = uniformRandom(texCoords.x * texCoords.y * (t + 100 + float(i)) * 1000.0);
    float radius = sqrt(noise1) * blur;
    float angle = noise2 * pi2;
    vec2 blurOffset = vec2(cos(angle) / aspectRatio, sin(angle)) * radius;

    vec3 sample = texture(sceneTex, texCoords + blurOffset).rgb;
    color.rgb += pow(sample, vec3(gamma, gamma, gamma));
  }

  color.rgb /= float(numSamples);

  color.rgb *= contrastBoost;

  color.rgb = pow(color.rgb, vec3(invCorrectedGamma, invCorrectedGamma, invCorrectedGamma));
}
