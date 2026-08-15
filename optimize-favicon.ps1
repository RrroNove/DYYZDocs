# ============================================================
# 优化 favicon.ico
# 源图:preview.png(原始 2048x2048,与原 favicon 相同)
# 处理:白底 -> 透明(保留蓝色徽记内的白色文字),抗锯齿边缘半透明
# 输出:16/32/48/64/128/256 多帧标准 .ico
# ============================================================
Add-Type -AssemblyName System.Drawing

$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$src = Join-Path $dir 'preview.png'        # 源图(原始 PNG)
$out = Join-Path $dir 'favicon.ico'        # 输出

$img = [System.Drawing.Image]::FromFile($src)

# ---------- 1. 缩放到 256 主图(ARGB) ----------
$S = 256
$master = New-Object System.Drawing.Bitmap($S, $S, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gr = [System.Drawing.Graphics]::FromImage($master)
$gr.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
$gr.InterpolationMode  = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gr.SmoothingMode      = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$gr.Clear([System.Drawing.Color]::Transparent)
$gr.DrawImage($img, 0, 0, $S, $S)
$gr.Dispose()
$img.Dispose()

# ---------- 2. LockBits 逐像素处理 ----------
$rect  = New-Object System.Drawing.Rectangle(0, 0, $S, $S)
$data  = $master.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$stride = $data.Stride
$bytes = New-Object byte[] ($stride * $S)
[System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)

$WHITE = 238

for ($y = 0; $y -lt $S; $y++) {
  $row = $y * $stride
  for ($x = 0; $x -lt $S; $x++) {
    $idx = $row + $x * 4
    $bb = [int]$bytes[$idx]        # B
    $gg = [int]$bytes[$idx+1]      # G
    $rr = [int]$bytes[$idx+2]      # R

    # 蓝色徽记主体
    if ($bb -ge 105 -and $bb -gt $rr -and $bb -gt $gg) { continue }
    # 红色圆环主体
    if ($rr -ge 140 -and $rr -gt $gg -and $rr -gt $bb -and (($rr - $gg) -ge 25)) { continue }

    $bright = [int](($rr + $gg + $bb) / 3)

    # 接近纯白:被蓝色包围则保留(白色文字),否则透明
    if ($rr -ge $WHITE -and $gg -ge $WHITE -and $bb -ge $WHITE) {
      $blueN = 0
      for ($dy = -1; $dy -le 1; $dy++) {
        for ($dx = -1; $dx -le 1; $dx++) {
          if ($dx -eq 0 -and $dy -eq 0) { continue }
          $nx = $x + $dx; $ny = $y + $dy
          if ($nx -ge 0 -and $nx -lt $S -and $ny -ge 0 -and $ny -lt $S) {
            $i2 = $ny * $stride + $nx * 4
            $br = [int]$bytes[$i2+2]; $bg = [int]$bytes[$i2+1]; $bbl = [int]$bytes[$i2]
            if ($bbl -ge 105 -and $bbl -gt $br -and $bbl -gt $bg) { $blueN++ }
          }
        }
      }
      if ($blueN -ge 4) { continue }   # 蓝色内的白色细节
      $bytes[$idx+3] = 0               # 背景 -> 透明
    }
    # 抗锯齿边缘:按亮度半透明
    elseif ($bright -gt 205) {
      $a = 255 - [int](($bright - 205) * 4.5)
      if ($a -lt 0)   { $a = 0 }
      if ($a -gt 255) { $a = 255 }
      $bytes[$idx+3] = [byte]$a
    }
  }
}

[System.Runtime.InteropServices.Marshal]::Copy($bytes, 0, $data.Scan0, $bytes.Length)
$master.UnlockBits($data)

# 预览
$master.Save((Join-Path $dir 'preview-transparent.png'), [System.Drawing.Imaging.ImageFormat]::Png)

# ---------- 3. 生成多尺寸 PNG 帧 ----------
$sizes = @(16, 32, 48, 64, 128, 256)
$frames = @()
foreach ($sz in $sizes) {
  $b = New-Object System.Drawing.Bitmap($sz, $sz, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $gb = [System.Drawing.Graphics]::FromImage($b)
  $gb.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $gb.InterpolationMode  = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $gb.SmoothingMode      = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $gb.Clear([System.Drawing.Color]::Transparent)
  $gb.DrawImage($master, 0, 0, $sz, $sz)
  $gb.Dispose()
  $ms = New-Object System.IO.MemoryStream
  $b.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
  $frames += , $ms.ToArray()
  $b.Dispose(); $ms.Dispose()
}
$master.Dispose()

# ---------- 4. 封装 ICO(内存流 + 一次性写入) ----------
$msOut = New-Object System.IO.MemoryStream
$bw = [System.IO.BinaryWriter]::new($msOut)
$count = $sizes.Count
$bw.Write([uint16]0)              # reserved
$bw.Write([uint16]1)              # type icon
$bw.Write([uint16]$count)         # count
$offset = 6 + 16 * $count
for ($i = 0; $i -lt $count; $i++) {
  $sz  = $sizes[$i]
  $png = $frames[$i]
  $dim = if ($sz -eq 256) { 0 } else { $sz }
  $bw.Write([byte]$dim)            # width
  $bw.Write([byte]$dim)            # height
  $bw.Write([byte]0)               # color count
  $bw.Write([byte]0)               # reserved
  $bw.Write([uint16]1)             # planes
  $bw.Write([uint16]32)            # bit count
  $bw.Write([uint32]$png.Length)   # bytes in res
  $bw.Write([uint32]$offset)       # offset
  $offset += $png.Length
}
foreach ($png in $frames) { $bw.Write($png) }
$bw.Flush()
[System.IO.File]::WriteAllBytes($out, $msOut.ToArray())
$bw.Dispose(); $msOut.Dispose()

Write-Host ('已生成: ' + $out)
Write-Host ('新大小: ' + ((Get-Item $out).Length) + ' 字节')
