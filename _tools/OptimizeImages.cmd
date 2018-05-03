for %%f in (*.png) do magick convert %%f -strip %%f

for %%f in (*.png) do magick convert %%f -strip %%~nf.webp