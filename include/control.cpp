#include "control.h"

std::string format_pipeline_mode(pipeline_control_t &ctrl) {
    std::string mode = "m_";
    switch (ctrl.overlay) {
        case MODE_OVERLAY_NONE:
            mode += "none";
            break;
        case MODE_OVERLAY_CHROMA_KEY:
            mode += "chroma";
            break;
        case MODE_OVERLAY_DIRECT:
            mode += "direct";
            break;
    }

    mode += "_s_";
    
    switch (ctrl.scale) {
        case MODE_SCALE_FULL:
            mode += "full";
            break;
        case MODE_SCALE_HALF:
            mode += "half";
            break;
        case MODE_SCALE_QUARTER:
            mode += "quarter";
            break;
    }

    mode += "_trs_" + std::to_string(ctrl.transparency);

    if (ctrl.offset_x != 0 || ctrl.offset_y != 0) {
        mode += "_off_" + std::to_string(ctrl.offset_x) + "_" + std::to_string(ctrl.offset_y);
    }
    
    if (ctrl.clip_left != 0 || ctrl.clip_right != 0 || ctrl.clip_top != 0 || ctrl.clip_bottom != 0) {
        mode += "_cl_" + std::to_string(ctrl.clip_left) + "_" + std::to_string(ctrl.clip_right) + "_" + std::to_string(ctrl.clip_top) + "_" + std::to_string(ctrl.clip_bottom);
    }

    return mode;
}