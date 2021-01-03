#include <stdio.h>
#include <intrinsic.h>
#include <arch/zx.h>

#define MAX_LEVEL_X 2
#define MAX_LEVEL_Y 2

extern unsigned char *screenTab[];
extern const unsigned char tile0[];
extern const unsigned char tileAttr[];
extern const unsigned char levels[];
extern void attribEdit(unsigned char *tileset, unsigned char *attrib);
extern unsigned char keyboardScan(void);
extern void displayScreen(void *scr);
extern void copyScreen(unsigned char xPos, unsigned char yPos,
        unsigned char *buffer);
extern void pasteScreen(unsigned char xPos, unsigned char yPos,
        unsigned char *buffer);
extern void displaySprite(unsigned char xPos, unsigned char yPos);
extern void cls(char attr)
__z88dk_fastcall;
extern unsigned char updateDirection(void)
__z88dk_fastcall;
extern void scroll(void)
__z88dk_fastcall;
extern void scrollInit(void *message)
__z88dk_fastcall;
extern void scrollReset(void)
__z88dk_fastcall;
void initISR(void)
__z88dk_fastcall;
void border(unsigned char color)
__z88dk_fastcall;
void initScore(void)
__z88dk_fastcall;
void displayScore(void)
__z88dk_fastcall;
void incScore(void)
__z88dk_fastcall;
void addScore(unsigned char value)
__z88dk_fastcall;
void lanternFlicker(void *lanterns)
__z88dk_fastcall;

extern void *lanternList;

#define FIRE    0x10
#define UP      0x08
#define DOWN    0x04
#define LEFT    0x02
#define RIGHT   0x01

inline void drawTile(unsigned char tileID, unsigned char x, unsigned char y)
{
    const unsigned char *tiles = &tile0[0];
    if (tileID)
    {
        for (unsigned char n = 0; n < 8; n++)
        {
            *(screenTab[(y << 3) + n] + x) = tiles[((tileID - 1) * 8) + n];
        }
    }
}

void brick(unsigned char *tileMap)
{
    for (unsigned char y = 0; y < 24; y++)
    {
        for (unsigned char x = 0; x < 32; x++)
        {
            drawTile(tileMap[(y * 32) + x], x, y);
        }
    }
}

unsigned char buffer[16];
unsigned char *tileMapData = &levels[0];
int main()
{
    int screenX = 0;
    int screenY = 0;
    int xPos = 40;
    int yPos = 40;
    char key = 0;
    unsigned char count = 0;
    static unsigned char dir;

    initISR();

    // Setup the screen and border
    cls(INK_WHITE | PAPER_BLACK);
    border(INK_BLACK);
    displayScreen(&levels[(screenY * (768*2)) + (screenX * 32)]);
    scrollInit(NULL);
    initScore();
    displayScore();

    copyScreen(xPos, yPos, buffer);

    while ((key = keyboardScan()) != '\n')
    {
        intrinsic_halt();
//        for(int a = 0; a<256; a++); // Delay so we can see the border on screen

        border(INK_WHITE);
        // Scroll the message
        scroll();

        border(INK_MAGENTA);
        // Scan Q, A, O, P, SPACE and update the direction flags accordingly
        dir = updateDirection();

        border(INK_RED);
        // Restore original contents of screen
        pasteScreen(xPos, yPos, buffer);

        //
        // Check for collisions and clear the direction bits accordingly
        //

        border(INK_BLUE);
        // Update to new position based on direction bits
        if (dir & UP)
        {
            if (yPos > 24)
            {
//                if ((tileMapData[(((yPos - 1) >> 3) * 32) + (xPos >> 3)] == 0xff)
//                        && (tileMapData[(((yPos - 1) >> 3) * 32)
//                                + ((xPos + 7) >> 3)] == 0xff))
                    yPos -= 1;
            }
            else
            {
                if(screenY > 0)
                {
                    screenY--;
                    yPos = 184;
                    cls(INK_WHITE | PAPER_BLACK);
                    displayScreen(&levels[(screenY * (768*2)) + (screenX * 32)]);
                    scrollReset();
                    displayScore();
                }
            }
        }
        else if (dir & DOWN)
        {
            if (yPos < (192 - 8))
            {
//                if ((tileMapData[(((yPos + 7 + 1) >> 3) * 32) + (xPos >> 3)]
//                        == 0xff)
//                        && (tileMapData[(((yPos + 7 + 1) >> 3) * 32)
//                                + ((xPos + 7) >> 3)] == 0xff))
                    yPos += 1;
            }
            else
            {
                if(screenY < (MAX_LEVEL_Y-1))
                {
                    screenY++;
                    yPos = 24;
                    cls(INK_WHITE | PAPER_BLACK);
                    displayScreen(&levels[(screenY * (768*2)) + (screenX * 32)]);
                    scrollReset();
                    displayScore();
                }
            }
        }

        if (dir & LEFT)
        {
            if (xPos >= 2)
            {
//                if ((tileMapData[((yPos >> 3) * 32) + ((xPos - 2) >> 3)] == 0xff)
//                        && (tileMapData[(((yPos + 7) >> 3) * 32)
//                                + ((xPos - 2) >> 3)] == 0xff))
                    xPos -= 2;
            }
            else
            {
                if(screenX > 0)
                {
                    screenX--;
                    xPos = 248;
                    cls(INK_WHITE | PAPER_BLACK);
                    displayScreen(&levels[(screenY * (768*2)) + (screenX * 32)]);
                    scrollReset();
                    displayScore();
                }
            }
        }
        else if (dir & RIGHT)
        {
            if (xPos < (256 - 8))
            {
//                if ((tileMapData[((yPos >> 3) * 32) + ((xPos + 7 + 2) >> 3)]
//                        == 0xff)
//                        && (tileMapData[(((yPos + 7) >> 3) * 32)
//                                + ((xPos + 7 + 2) >> 3)] == 0xff))
                    xPos += 2;
            }
            else
            {
                if(screenX < (MAX_LEVEL_X-1))
                {
                    screenX++;
                    xPos = 0;
                    cls(INK_WHITE | PAPER_BLACK);
                    displayScreen(&levels[(screenY * (768*2)) + (screenX * 32)]);
                    scrollReset();
                    displayScore();
                }
            }
        }

        if (dir & FIRE)
        {
            ;
        }

        border(INK_YELLOW);
        // Copy contents of screen at new location
        copyScreen(xPos, yPos, buffer);

        border(INK_CYAN);
        displaySprite(xPos, yPos);

        border(INK_GREEN);
        if(count++ >= 50)
        {
            addScore(0x17);
//            incScore();
            count = 0;
            displayScore();
        }

        border(INK_RED);
        lanternFlicker(&lanternList);
        border(INK_BLACK);
        if (key == 'S')
        {
            attribEdit(tile0, tileAttr);
            cls(INK_WHITE | PAPER_BLACK);
            displayScreen(&levels[(screenY * (768*2)) + (screenX * 32)]);
            scrollInit(NULL);
        }
    }

    intrinsic_di();
    return (0);
}
