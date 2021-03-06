/*
 * Copyright 2012 Benjamin Glatzel <benjamin.glatzel@me.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

varying vec4 vertexProjPos;
varying vec3 eyeVec;

uniform vec3 lightViewPos;

uniform sampler2D texSceneOpaqueDepth;
uniform sampler2D texSceneOpaqueNormals;

uniform vec3 lightColorDiffuse = vec3(1.0, 0.0, 0.0);
uniform vec3 lightColorAmbient = vec3(1.0, 0.0, 0.0);

uniform vec4 lightProperties;
#define lightDiffuseIntensity lightProperties.y
#define lightAmbientIntensity lightProperties.x
#define lightSpecularIntensity lightProperties.z
#define lightSpecularPower lightProperties.w

uniform vec4 lightExtendedProperties;
#define lightAttenuationRange lightExtendedProperties.x
#define lightAttenuationFalloff lightExtendedProperties.y

uniform mat4 invProjMatrix;

void main() {

#if defined (FEATURE_LIGHT_POINT)
    vec2 projectedPos = projectVertexToTexCoord(vertexProjPos);
#else
    vec2 projectedPos = gl_TexCoord[0].xy;
#endif

    vec3 normal = normalize(texture2D(texSceneOpaqueNormals, projectedPos.xy).rgb * 2.0 - 1.0);
    float depth = texture2D(texSceneOpaqueDepth, projectedPos.xy).r * 2.0 - 1.0;

    // TODO: Costly - would be nice to use Crytek's view frustum ray method at this point
    vec3 viewSpacePos = reconstructViewPos(depth, projectedPos, invProjMatrix);

    vec3 color = lightColorAmbient * lightAmbientIntensity;

    vec3 lightDir = lightViewPos.xyz - viewSpacePos;
    float lightDist = length(lightDir);
    vec3 lightDirNorm = lightDir / lightDist;

    float lambTerm = calcLambLight(normal, lightDirNorm);
    float specTerm  = calcSpecLight(normal, lightDirNorm, eyeVec, lightSpecularPower);

    float specular = lightSpecularIntensity * specTerm;

    color += lightColorDiffuse * lightDiffuseIntensity * lambTerm;

#if defined (FEATURE_LIGHT_POINT)
    //float attenuation = clamp (1.0 - ((lightDist * lightDist) / (lightAttenuationRange * lightAttenuationRange)), 0.0, 1.0);
    float attenuation = clamp(1.0 - (pow (lightDist, lightAttenuationFalloff) / lightAttenuationRange), 0.0, 1.0);

    specular *= attenuation;
    color *= attenuation;
#endif

    gl_FragData[0].rgba = vec4(color.r, color.g, color.b, specular);
}
