Pod::Spec.new do |spec|
  spec.name         = "NetworkModule"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of NetworkModule."

  spec.description  = <<-DESC
Framework NetworkModule is used for creating network layer.
                   DESC

  spec.homepage     = "http://github.com/dmakarevich/NetworkModule"
  spec.license      = { :type => 'Proprietary', :text => 'Proprietary' }
  spec.author       = { "Dmitry Makarevich" => "d.a.makarevch@gmail.com" }
  spec.source       = { :git => "git@github.com:dmakarevich/NetworkModule.git", :tag => spec.version.to_s }

  spec.ios.deployment_target = "13.0"
  spec.swift_version = "5.5"

  spec.source_files  = 'Sources/**/*'
end
