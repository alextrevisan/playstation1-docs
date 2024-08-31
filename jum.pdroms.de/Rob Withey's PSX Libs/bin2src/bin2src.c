/* bin2src:
 *
 * -L<labelname> - defines label to output in srce
 * -A            - outputs as R3000 assembly language
 * -C            - outputs as C source code (default)
 * -Fi<filename> - input filename
 * -Fo<filename> - output filename
 */

#include <stdio.h>

static int
ConvertBin2C(char *inName, char *outName, char *label)
{
    FILE    *fptrIn;
    FILE    *fptrOut;
    int     xPos = 0;
    int     needComma = 0;

    fptrIn = fopen(inName, "rb");
    if (!fptrIn)
    {
        fprintf(stderr, "Failed to open input file '%s'\n", inName);
        return(1);
    }

    fptrOut = fopen(outName, "wt");
    if (!fptrOut)
    {
        fprintf(stderr, "Failed to open output file '%s'\n", outName);
        fclose(fptrIn);
        return(1);
    }

    fprintf(fptrOut, "unsigned char %s[] = {\n", label);

    while (!feof(fptrIn))
    {
        int     byteIn;
        byteIn = fgetc(fptrIn);

        if (byteIn >= 0)
        {
            if (needComma)
            {
                if (xPos == 0)
                {
                    /* This is the end of the line */
                    fprintf(fptrOut, ",\n");
                }
                else
                {
                    fprintf(fptrOut, ", ");
                }
            }
            fprintf(fptrOut, "0x%02x", byteIn);
            needComma = 1;

            xPos++;
            xPos &= 7;
        }
    }

    fprintf(fptrOut, "};\n");

    fclose(fptrOut);
    fclose(fptrIn);

    return(0);
}

static int
ConvertBin2R3000(char *inName, char *outName, char *label)
{
    FILE    *fptrIn;
    FILE    *fptrOut;
    int     xPos = 0;

    fptrIn = fopen(inName, "rb");
    if (!fptrIn)
    {
        fprintf(stderr, "Failed to open input file '%s'\n", inName);
        return(1);
    }

    fptrOut = fopen(outName, "wt");
    if (!fptrOut)
    {
        fprintf(stderr, "Failed to open output file '%s'\n", outName);
        fclose(fptrIn);
        return(1);
    }

    fprintf(fptrOut, "%s:", label);

    while (!feof(fptrIn))
    {
        int     byteIn;
        byteIn = fgetc(fptrIn);

        if (byteIn >= 0)
        {
            if (xPos == 0)
            {
                /* Start of the line */
                fprintf(fptrOut, "\n\t.byte\t0x%02x", byteIn);
            }
            else
            {
                fprintf(fptrOut, ", 0x%02x", byteIn);
            }

            xPos++;
            xPos &= 7;
        }
    }

    fprintf(fptrOut, "\n");

    fclose(fptrOut);
    fclose(fptrIn);

    return(0);
}

int
main(int argc, char *argv[])
{
    char    *outName = NULL;
    char    *inName = NULL;
    char    *label = NULL;
    int     outAsC = 1;

    /* Skip app name */
    argv++;
    argc--;

    while (argc--)
    {
        if ((*argv)[0] == '-')
        {
            if ((*argv)[1] == 'L')
            {
                label = &(*argv)[2];
            }
            else if ((*argv)[1] == 'A')
            {
                outAsC = 0;
            }
            else if ((*argv)[1] == 'C')
            {
                outAsC = 1;
            }
            else if ((*argv)[1] == 'F')
            {
                if ((*argv)[2] == 'i')
                {
                    inName = &(*argv)[3];
                }
                else if ((*argv)[2] == 'o')
                {
                    outName = &(*argv)[3];
                }
                else
                {
                    fprintf(stderr, "Unknown option '%s'\n", argv);
                }
            }
            else
            {
                fprintf(stderr, "Unknown option '%s'\n", argv);
            }
        }
        else
        {
            fprintf(stderr, "Unknown option '%s'\n", argv);
        }

        argv++;
    }

    if (!outName)
    {
        fprintf(stderr, "Output filename not specified\n");
        return(1);
    }

    if (!inName)
    {
        fprintf(stderr, "Input filename not specified\n");
        return(1);
    }

    if (!label)
    {
        fprintf(stderr, "Label not specified\n");
        return(1);
    }

    if (outAsC)
    {
        return(ConvertBin2C(inName, outName, label));
    }
    else
    {
        return(ConvertBin2R3000(inName, outName, label));
    }
}
