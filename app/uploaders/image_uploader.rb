class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :thumb do
    process resize_to_fit: [100, 100]
  end

  def extension_allowlist
    %w(jpg jpeg gif png)
  end

  def default_url(*args)
    "fallback/" + [version_name, "default.png"].compact.join('_')
  end
end