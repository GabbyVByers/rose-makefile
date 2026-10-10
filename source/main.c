
/*
 *   Source File [main.c]
 */

#include "rose.h"

int main(void)
{
    ROSE_Init("Title", 500, 500, true);
    ROSE_WindowToggleVSync(true);

    ROSE_Image* image = ROSE_ImageCreate(100, 200);
    ROSE_Sprite* sprite = ROSE_SpriteCreate(image);

    while (ROSE_WindowIsOpen())
    {
        i32 mouse_x = ROSE_MousePositionX();
        i32 mouse_y = ROSE_MousePositionY();

        ROSE_WindowClearFrame(ROSE_COLOR(80, 80, 80, 255));
        ROSE_SpriteDraw(sprite, mouse_x, mouse_y, 1.0f, ROSE_COLOR_WHITE);
        ROSE_WindowRenderFrame();
    }

    ROSE_Quit();
    return EXIT_SUCCESS;
}

