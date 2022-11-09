#include <verilated.h>

#include <iostream>

#include "Vpipeline_chroma_key.h"
#include "lodepng.h"

Vpipeline_chroma_key *top;

/*
3 ways to decode a PNG from a file to RGBA pixel data (and 2 in-memory ways).
*/

// g++ lodepng.cpp example_decode.cpp -ansi -pedantic -Wall -Wextra -O3

// Example 1
// Decode from disk to raw pixels with a single function call
void decodeOneStep(const char *filename) {
    std::vector<unsigned char> image;  // the raw pixels
    unsigned width, height;

    // decode
    unsigned error = lodepng::decode(image, width, height, filename);

    // if there's an error, display it
    if (error) {
        std::cout << "decoder error " << error << ": "
                  << lodepng_error_text(error) << std::endl;
    }

    // the pixels are now in the vector "image", 4 bytes per pixel, ordered
    // RGBARGBA..., use it as texture, draw it, ...
}

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    top = new Vpipeline_chroma_key;

    top->final();
    delete top;
}
