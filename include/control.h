#ifndef MODE_HELPER_H
#define MODE_HELPER_H

#include <string>

typedef enum {
    MODE_SCALE_FULL = 0b00,
    MODE_SCALE_HALF = 0b01,
    MODE_SCALE_QUARTER = 0b10
} mode_scale_t;

typedef enum {
    MODE_OVERLAY_NONE = 0b00,
    MODE_OVERLAY_CHROMA_KEY = 0b01,
    MODE_OVERLAY_DIRECT = 0b10
} mode_overlay_t;

typedef enum {
    CMD_RESET = 0x0,
    CMD_FG_MODE = 0x1,
    CMD_FG_MODE_FLAGS = 0x2,
    CMD_FG_SCALE = 0x3,
    CMD_FG_OFFSET_X = 0x4,
    CMD_FG_OFFSET_Y = 0x5,
    CMD_FG_TRANSPARENCY = 0x6,
    CMD_FG_CLIP_LEFT = 0x7,
    CMD_FG_CLIP_RIGHT = 0x8,
    CMD_FG_CLIP_TOP = 0x9,
    CMD_FG_CLIP_BOTTOM = 0xA,
    CMD_FG_FREEZE = 0xB,
    CMD_FG_IMG_UPLOAD = 0xC,
} command_t;

typedef struct {
    mode_overlay_t overlay;
    mode_scale_t scale;
    uint8_t opacity;
    
    int16_t offset_x;
    int16_t offset_y;

    uint16_t clip_left;
    uint16_t clip_right;
    uint16_t clip_top;
    uint16_t clip_bottom;
} pipeline_control_t;

std::string format_pipeline_mode(pipeline_control_t &ctrl);

#endif