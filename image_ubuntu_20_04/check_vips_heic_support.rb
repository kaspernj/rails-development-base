#!/usr/bin/env ruby

require "vips"

suffixes = Vips.get_suffixes

puts "Supported suffixes: #{suffixes}"

expected_to_support_list = [
  ".csv", ".mat", ".raw", ".v", ".vips", ".pbm", ".pgm", ".ppm", ".pfm", ".hdr", ".dz", ".png", ".jpg", ".jpeg", ".jpe", ".webp", ".tif", ".tiff", ".fits",
  ".fit", ".fts", ".nii", ".nii.gz", ".hdr.gz", ".img", ".img.gz", ".nia", ".nia.gz", ".heic", ".heif", ".avif", ".bmp", ".gif"
]
unsupported = []
expected_to_support_list.each do |format_to_support|
  unsupported << format_to_support unless suffixes.include?(format_to_support)
end

raise "VIPS doesn't support #{unsupported.join(", ")}" if unsupported.length > 0
