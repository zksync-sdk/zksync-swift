Pod::Spec.new do |s|
  s.name             = 'ZKSyncSDK'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ZKSyncSDK.'

  s.description      = <<-DESC
zkSync is a scaling and privacy engine for Ethereum. Its current functionality scope includes low gas transfers of ETH and ERC20 tokens in the Ethereum network
                       DESC

  s.homepage         = "https://github.com/zksync-sdk/zksync-sdk-swift"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  
  s.author           = { "The Matter Labs team" => "hello@matterlabs.dev" }
  
  s.ios.deployment_target = "10.0"
  s.swift_version = '5.0'
  
  s.source       = { :git => "https://github.com/zksync-sdk/zksync-sdk-swift.git", :tag => "#{s.version}" }

  s.source_files = 'ZKSyncSDK/Classes/**/*'
  
  s.dependency 'BigInt', '~> 5.2'
#  s.dependency 'ZKCryptoSDK'
end
