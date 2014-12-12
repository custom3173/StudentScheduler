# some simple color manipulation utilities
#  todo: should probably add support for opacity
class window.Colors

  # calculate a contrasting color in the same hue that is suitable
  #  as a background for text in the original color
  @bgContrast: (hex) ->
    [r, g, b] = @parseHex hex
    [r, g, b] = @normalizeRGB r, g, b
    [h, s, l] = @toHSL r, g, b

    l = @contrastLuma [r, g, b]
    @cssHSL h, s, l

  # select an appropriately contrasting lightness from an
  #  evaluation of the color's luminance (apparent brightness)
  @contrastLuma: (rgb) ->
    luma = 0.2126*rgb[0] + 0.7152*rgb[1] + 0.0722*rgb[2]
    if luma >= 0.5 then 0.15 else 0.85

  # convert 8bit RGB to linear [0,1]
  @normalizeRGB: (r, g, b) ->
    [r/255, g/255, b/255]

  # convert hex string to RGB
  @parseHex: (hex) ->
    hex = hex.substring(1) if hex.charAt(0) == '#'

    r = parseInt hex.substr(0,2), 16
    g = parseInt hex.substr(2,2), 16
    b = parseInt hex.substr(4,2), 16

    [r, g, b]

  # transform normalized rgb color to hsl
  #  duplicated from css so returned values can 
  #  be displayed directly without conversion
  @toHSL: (r, g, b) ->
    min = Math.min(r, g, b)
    max = Math.max(r, g, b)
    chroma = max - min

    if chroma == 0
      h = 0
    else if r == max
      h = (((g - b) / chroma) % 6) * 60
    else if g == max
      h = (((b - r) / chroma) + 2) * 60
    else
      h = (((r - g) / chroma) + 4) * 60

    l = (min + max)/2

    if l == 0 || l == 1
      s = 0
    else
      s = chroma / (1 - Math.abs(2 * l - 1))

    [h, s, l]

  # dump hsl output suitable for css
  @cssHSL: (h, s, l) ->
    "hsl(#{ Math.round(h) }, #{ Math.round(s*100) }%, #{ Math.round(l*100) }%)"