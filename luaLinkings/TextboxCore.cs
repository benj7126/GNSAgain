using GNSUsingCS;
using NLua;
using Raylib_cs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace GNSAgain.luaLinkings
{
    internal class TextboxChars(int codepoint) // should i just store the position / AABB as well?
    {
        public int codepoint = codepoint;
    }
    enum Wrapping
    {
        CharWrapping, // normal(?) wrapping
        WordWrapping, // word wrappoing
        NoWrapping // no wrapping at all
    }
    internal unsafe class CodepointCounter
    {
        [LuaMethod("rl")]
        private static CodepointCounter getCodepointCounter(string text, string fontName, int fontSize, float spacing = 0)
        {
            return new CodepointCounter(text, fontName, fontSize, spacing);
        }

        sbyte* cText;
        Font font;
        float scaleFactor;
        float spacing;

        int size;
        int currentByte = 0;

        int codepoint;
        float charWidth;

        public CodepointCounter(string text, string fontName, int fontSize, float spacing)
        {
            cText = text.ToUtf8Buffer().AsPointer();

            font = FontManager.getFont(fontName, fontSize);
            scaleFactor = fontSize / (float)font.BaseSize;

            size = (int)TextLength(cText);

            this.spacing = spacing;


            int byteCount = 0;

            codepoint = GetCodepointNext(&cText[currentByte], &byteCount);
            int codepointIndex = GetGlyphIndex(font, codepoint);
            charWidth = GetCodepointWidth(codepointIndex);

            currentByte += byteCount;
        }

        [LuaMethod("rl")] // takes a string; but only looks at the first char.

        unsafe static public float getCharWidth(string c, string fontName, int fontSize, float spacing)
        {
            Font font = FontManager.getFont(fontName, fontSize);
            float scaleFactor = fontSize / (float)font.BaseSize;

            int byteCount = 0;
            
            int codepoint = GetCodepointNext(c.ToUtf8Buffer().AsPointer(), &byteCount);
            int codepointIndex = GetGlyphIndex(font, codepoint);

            return (font.Glyphs[codepointIndex].AdvanceX == 0 ? (float)font.Recs[codepointIndex].Width : (float)font.Glyphs[codepointIndex].AdvanceX) * scaleFactor + spacing;
        }

        unsafe private float GetCodepointWidth(int idx)
        {
            return (font.Glyphs[idx].AdvanceX == 0 ? (float)font.Recs[idx].Width : (float)font.Glyphs[idx].AdvanceX) * scaleFactor + spacing;
            // need to add spacing manually after getting width
        }

        public bool hasNext()
        {
            return currentByte <= size; // might be wrong - likely is
        }

        // bytecount
        public (int, float, float) nexCodepoint()
        {
            int nextByteCount = 0;

            int nextCodepoint = GetCodepointNext(&cText[currentByte], &nextByteCount);
            int nextCodepointIndex = GetGlyphIndex(font, nextCodepoint);
            float nextCharWidth = GetCodepointWidth(nextCodepointIndex);

            (int, float, float) ret = (codepoint, charWidth, nextCharWidth); // should add spacing

            currentByte += nextByteCount;

            codepoint = nextCodepoint;
            charWidth = nextCharWidth;

            return ret;

            /*
            int byteCount = nextByteCount;
            codepoint = nextCodepoint;
            cpIndex = nextCodepointIndex;
            charWidth = nextCharWidth;

            if (i + nextByteCount != size)
            {
                nextCodepoint = GetCodepointNext(&cText[i + nextByteCount], &nextByteCount);
                nextCodepointIndex = GetGlyphIndex(font, nextCodepoint);
                nextCharWidth = GetCodepointWidth(nextCodepointIndex);
            }
            else
            {
                nextCharWidth = 0;
            }
            */
        }
    }
    

    internal class TextboxCore
    {
        [LuaMethod("rl")]
        private static TextboxCore getTextbox()
        {
            return new TextboxCore();   
        }

        int fontSize = 20;

        float spacing = 0.2f;
        float lineSpacing = 0.2f;

        public Wrapping wrapping = 0;

        static int cursorVisualX = 0;
        static int cursorVisualY = 0;

        static int savedCursorVisualX = -1;
        static int savedCursorVisualY = -1;
        static int cursorPosition = 0;

        static int highlightPosition = -1;

        List<List<TextboxChars>> lines = [];

        unsafe private float GetCodepointWidth(int idx)
        {
            Font font = FontManager.getFont("", fontSize);
            float scaleFactor = fontSize / (float)font.BaseSize;
            return (font.Glyphs[idx].AdvanceX == 0 ? (float)font.Recs[idx].Width : (float)font.Glyphs[idx].AdvanceX) * scaleFactor + spacing;
        }
        private void InsertBuffer(List<TextboxChars> lineBuffer, List<Tuple<int, float>> codepointBuffer, Vector2 mPos, ref int curIndex, ref float textOffsetX, ref bool setCursor, float textOffsetY)
        {
            foreach (Tuple<int, float> cpNWidth in codepointBuffer)
            {
                if (setCursor)
                {
                    if (mPos.Y < textOffsetY + lineSpacing + fontSize && mPos.X < textOffsetX + cpNWidth.Item2 / 2f)
                    {
                        cursorPosition = curIndex;
                        setCursor = false;
                    }
                }

                if (curIndex == cursorPosition && cursorVisualX == -1) // && InputManager.CheckSelected(this))
                {
                    cursorVisualX = (int)textOffsetX;
                    cursorVisualY = (int)textOffsetY;
                }

                curIndex++;
                textOffsetX += cpNWidth.Item2;

                lineBuffer.Add(new(cpNWidth.Item1));
            }
        }

        unsafe public void PrepareTexbox(string text, int x, int y, int w, int h, int mx = -1, int my = -1)
        {
            PrepareTexbox(text, x, y, w, h, mx == -1 && my == -1 ? null : new Vector2(mx, my));
        }
        private bool InBetween(int val, int v1, int v2)
        {
            if (v1 > v2)
                return val < v1 && val > v2 - 1;
            else
                return val < v2 && val > v1 - 1;
        }

        unsafe public void DrawCodepoints(int x, int y, int w, int h)
        {
            Font font = FontManager.getFont("", fontSize);

            int curIndex = 0;
            float textOffsetY = 0;
            float textOffsetX = 0;

            foreach (List<TextboxChars> lineBuffer in lines)
            {
                foreach (TextboxChars tc in lineBuffer)
                {
                    int index = GetGlyphIndex(font, tc.codepoint);
                    float cWidth = GetCodepointWidth(index);

                    if (highlightPosition != cursorPosition && highlightPosition != -1 && InBetween(curIndex, highlightPosition, cursorPosition))
                    {
                        DrawRectangle(x + (int)Math.Floor(textOffsetX), y + (int)Math.Floor(textOffsetY), (int)Math.Ceiling(cWidth), fontSize, Color.Gray);
                    }

                    if ((tc.codepoint != ' ') && (tc.codepoint != '\t'))
                    {
                        DrawTextCodepoint(font, tc.codepoint, new Vector2(x + textOffsetX, y + textOffsetY), fontSize, Color.Black);
                    }

                    curIndex++; // idk if this should be here or before, but whatever...
                    textOffsetX += cWidth;
                }
                textOffsetY += fontSize + lineSpacing;
                textOffsetX = 0;
            }

            /*
            foreach (List<TextboxChars> lineBuffer in lines)
            {
                foreach (TextboxChars tc in lineBuffer)
                {
                    int index = GetGlyphIndex(font, tc.codepoint);
                    float cWidth = GetCodepointWidth(index);

                    if (InputManager.CheckSelected(this) && highlightPosition != cursorPosition && highlightPosition != -1 && InBetween(curIndex, highlightPosition, cursorPosition))
                    {
                        DrawRectangle(x + (int)Math.Floor(textOffsetX) - (int)scroll.X, y + (int)Math.Floor(textOffsetY) - (int)scroll.Y, (int)Math.Ceiling(cWidth), fontSize, Color.Gray);
                    }

                    if ((tc.codepoint != ' ') && (tc.codepoint != '\t'))
                    {
                        DrawTextCodepoint(font, tc, new Vector2(x + textOffsetX, y + textOffsetY) - scroll, fontSize, Color.Black);
                    }

                    curIndex++; // idk if this should be here or before, but whatever...
                    textOffsetX += cWidth;
                }
                textOffsetY += fontSize + lineSpacing;
                textOffsetX = 0;
            }
            */
        }

        /// <summary>
        /// Handles some logic and prepeares the text to be drawn.
        /// </summary>
        unsafe private void PrepareTexbox(string text, int x, int y, int w, int h, Vector2? cursorPos = null)
        {
            lines.Clear();
            // Font font = FontManager.getFont("", fontSize); // FontManager.GetFont(FontType, FontSize);
            CodepointCounter CPC = new CodepointCounter(text, "", fontSize, spacing);

            List<Tuple<int, float>> codepointBuffer = [];
            List<TextboxChars> lineBuffer = [];
            float codepointBufferWidth = 0;
            float curLineWidth = 0;

            int curIndex = 0;

            float textOffsetY = 0;
            float textOffsetX = 0;
            float peakTextOffsetX = 0;

            float prevCursorX = cursorVisualX;
            float prevCursorY = cursorVisualY;

            if (true) // (InputManager.CheckSelected(this))
            {
                cursorVisualX = -1;
                cursorVisualY = -1;
            }

            bool setCursor = IsMouseButtonPressed(MouseButton.Left) || cursorPos is not null; //  IsHovered && IsMouseButtonPressed(MouseButton.Left) || cursorPos is not null;
            // cursorPos ??= MouseManager - new Vector2(x, y); // + _scroll;
            Vector2 mPos = cursorPos.Value;

            if (setCursor)
            {
                if (mPos.Y < 0)
                {
                    savedCursorVisualX = -1;
                    cursorPosition = 0;
                    setCursor = false;

                    cursorVisualX = (int)textOffsetX;
                    cursorVisualY = (int)textOffsetY;
                }
                else
                {
                    cursorPosition = -1;
                }
            }

            while (CPC.hasNext())
            {
                (int, float, float) cppair = CPC.nexCodepoint();

                int codepoint = cppair.Item1;
                float charWidth = cppair.Item2;
                float nextCharWidth = cppair.Item3;

                /*
                if (i + nextByteCount != size)
                {
                    nextCodepoint = GetCodepointNext(&cText[i + nextByteCount], &nextByteCount);
                    nextCharWidth = GetCodepointWidth(nextCodepointIndex);
                }
                else
                {
                    nextCharWidth = 0; 
                }
                */

                if (codepoint == '\n')
                {
                    InsertBuffer(lineBuffer, codepointBuffer, mPos, ref curIndex, ref textOffsetX, ref setCursor, textOffsetY);
                    codepointBuffer = [];

                    if (setCursor)
                    {
                        if (mPos.Y < textOffsetY + lineSpacing + fontSize)
                        {
                            cursorPosition = curIndex;
                            setCursor = false;

                            cursorVisualX = (int)textOffsetX;
                            cursorVisualY = (int)textOffsetY;
                        }
                    }

                    InsertBuffer(lineBuffer, [new(' ', 0)], mPos, ref curIndex, ref textOffsetX, ref setCursor, textOffsetY);
                    lines.Add(lineBuffer);
                    lineBuffer = [];
                    codepointBufferWidth = 0;

                    curLineWidth = 0;
                    textOffsetY += lineSpacing + fontSize;
                    peakTextOffsetX = MathF.Max(peakTextOffsetX, textOffsetX);
                    textOffsetX = 0;
                }
                else
                {
                    codepointBuffer.Add(new(codepoint, charWidth));
                    codepointBufferWidth += charWidth;

                    if (codepoint == ' ' || codepoint == '\t' || wrapping == Wrapping.CharWrapping || wrapping == Wrapping.NoWrapping || curLineWidth + nextCharWidth + codepointBufferWidth > w)
                    {
                        if (curLineWidth + nextCharWidth + codepointBufferWidth > w && wrapping != Wrapping.NoWrapping && !(codepoint == ' ' || codepoint == '\t'))
                        {
                            //bool wasZero = curLineWidth == 0;

                            if (wrapping == Wrapping.WordWrapping && curLineWidth != 0)
                            {
                                lines.Add(lineBuffer);
                                lineBuffer = [];
                                curLineWidth = 0;
                            }
                            else
                            {
                                InsertBuffer(lineBuffer, codepointBuffer, mPos, ref curIndex, ref textOffsetX, ref setCursor, textOffsetY);
                                lines.Add(lineBuffer);
                                lineBuffer = [];
                                codepointBuffer = [];
                                codepointBufferWidth = 0;
                                curLineWidth = 0;
                            }

                            if (setCursor)
                            {
                                if (mPos.Y < textOffsetY + lineSpacing + fontSize)
                                {
                                    cursorPosition = curIndex;
                                    setCursor = false;

                                    cursorVisualX = (int)textOffsetX;
                                    cursorVisualY = (int)textOffsetY;
                                }
                            }

                            textOffsetY += lineSpacing + fontSize;
                            peakTextOffsetX = MathF.Max(peakTextOffsetX, textOffsetX);
                            textOffsetX = 0;
                        }
                        else
                        {
                            InsertBuffer(lineBuffer, codepointBuffer, mPos, ref curIndex, ref textOffsetX, ref setCursor, textOffsetY);
                            codepointBuffer = [];
                            curLineWidth += codepointBufferWidth;
                            codepointBufferWidth = 0;

                        }
                    }
                }
            }

            InsertBuffer(lineBuffer, codepointBuffer, mPos, ref curIndex, ref textOffsetX, ref setCursor, textOffsetY);
            lines.Add(lineBuffer);
            curLineWidth += codepointBufferWidth;
            codepointBufferWidth = 0;

            if (setCursor)
            {
                cursorPosition = text.Length;
            }

            if (cursorVisualX == -1) // && InputManager.CheckSelected(this))
            {
                savedCursorVisualX = -1;
                cursorVisualX = (int)textOffsetX;
                cursorVisualY = (int)textOffsetY;
            }

            peakTextOffsetX = MathF.Max(peakTextOffsetX, textOffsetX);
            /* would like this to be an eventListener thing in lua somehow...
            _scrollRoom = new(peakTextOffsetX - w, textOffsetY + fontSize - h);

            int SODown = heldMode == HeldMode.Nothing ? Settings.ScrollOffDown : 0;
            int SOUp = heldMode == HeldMode.Nothing ? Settings.ScrollOffUp : 0;

            if (prevCursorX != cursorVisualX || prevCursorY != cursorVisualY)
            {
                if ((cursorVisualY + fontSize - scroll.Y + fontSize * SODown) > h)
                {
                    scroll.Y = (cursorVisualY + fontSize) - h + fontSize * SODown;
                }
                if ((cursorVisualY - scroll.Y - fontSize * SOUp) < 0)
                {
                    scroll.Y = cursorVisualY - fontSize * SOUp;
                }

                if ((cursorVisualX + fontSize - scroll.X) > w)
                {
                    scroll.X = (cursorVisualX + fontSize) - w;
                }
                if ((cursorVisualX - scroll.X) < 0)
                {
                    scroll.X = cursorVisualX;
                }
            }
            */
        }
    }
}