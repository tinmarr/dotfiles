static const char norm_fg[] = "#dec5e2";
static const char norm_bg[] = "#060410";
static const char norm_border[] = "#9b899e";

static const char sel_fg[] = "#dec5e2";
static const char sel_bg[] = "#524BB4";
static const char sel_border[] = "#dec5e2";

static const char urg_fg[] = "#dec5e2";
static const char urg_bg[] = "#553296";
static const char urg_border[] = "#553296";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
    [SchemeUrg] =  { urg_fg,      urg_bg,    urg_border },
};
