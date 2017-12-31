#include <metal_texture>
#include <metal_matrix>

using namespace metal;

struct SolidVertexOutput
{
	float4 position [[position]];
	float pointSize [[point_size]];
};

vertex SolidVertexOutput SDL_Solid_vertex(const device float2 *position [[buffer(0)]],
                                          constant float4x4 &projection [[buffer(2)]],
                                          uint vid [[vertex_id]])
{
    SolidVertexOutput v;
	v.position = projection * float4(position[vid].x, position[vid].y, 0.0f, 1.0f);
	v.pointSize = 0.5f;
	return v;
}
 
fragment float4 SDL_Solid_fragment(constant float4 &col [[buffer(0)]])
{
    return col;
}

struct CopyVertexOutput
{
    float4 position [[position]];
    float2 texcoord;
};

vertex CopyVertexOutput SDL_Copy_vertex(const device float2 *position [[buffer(0)]],
                                        const device float2 *texcoords [[buffer(1)]],
                                        constant float4x4 &projection [[buffer(2)]],
                                        uint vid [[vertex_id]])
{
    CopyVertexOutput v;
    v.position = projection * float4(position[vid].x, position[vid].y, 0.0f, 1.0f);
    v.texcoord = texcoords[vid];
    return v;
}

fragment float4 SDL_Copy_fragment_nearest(CopyVertexOutput vert [[stage_in]],
                                          constant float4 &col [[buffer(0)]],
                                          texture2d<float> tex [[texture(0)]])
{
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::nearest);
    return tex.sample(s, vert.texcoord) * col;
}

fragment float4 SDL_Copy_fragment_linear(CopyVertexOutput vert [[stage_in]],
                                         constant float4 &col [[buffer(0)]],
                                         texture2d<float> tex [[texture(0)]])
{
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
    return tex.sample(s, vert.texcoord) * col;
}

