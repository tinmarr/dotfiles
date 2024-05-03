const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#060410", /* black   */
  [1] = "#553296", /* red     */
  [2] = "#524BB4", /* green   */
  [3] = "#614AA2", /* yellow  */
  [4] = "#9E589E", /* blue    */
  [5] = "#B659B5", /* magenta */
  [6] = "#7A84EA", /* cyan    */
  [7] = "#dec5e2", /* white   */

  /* 8 bright colors */
  [8]  = "#9b899e",  /* black   */
  [9]  = "#553296",  /* red     */
  [10] = "#524BB4", /* green   */
  [11] = "#614AA2", /* yellow  */
  [12] = "#9E589E", /* blue    */
  [13] = "#B659B5", /* magenta */
  [14] = "#7A84EA", /* cyan    */
  [15] = "#dec5e2", /* white   */

  /* special colors */
  [256] = "#060410", /* background */
  [257] = "#dec5e2", /* foreground */
  [258] = "#dec5e2",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
