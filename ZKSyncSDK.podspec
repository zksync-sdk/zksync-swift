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
  
    s.ios.deployment_target = "9.0"
    s.swift_version = '5.0'
  
    s.source       = { :git => "https://github.com/zksync-sdk/zksync-sdk-swift.git", :tag => "#{s.version}" }
    
    s.module_map = "ZKSyncSDK/ZKSyncSDK.modulemap"
    
    s.vendored_libraries = "ZKSyncSDK/libzks/*.a"

#    s.pod_target_xcconfig = {
##        'MODULEMAP_PRIVATE_FILE' => '$(PODS_ROOT)/../../ZKSyncSDK/ZKSyncSDK.private.modulemap',
#        'HEADER_SEARCH_PATHS' => '"$(PODS_ROOT)/../../ZKSyncSDK/Headers"'
#    }

    s.default_subspec = 'Core'

    s.subspec 'Core' do |core|
        core.source_files = 'ZKSyncSDK/Classes/**/*', 'ZKSyncSDK/Headers/*.h'

        core.dependency 'BigInt', '~> 5.2'
        core.dependency 'ZKSyncSDK/Crypto'
    end

    s.subspec 'Crypto' do |crypto|
        crypto.source_files = 'ZKCryptoSDK/Classes/**/*'

        crypto.pod_target_xcconfig = { :VALID_ARCHS => 'arm64 arm64e armv7 armv7s x86_64' }
    end
end
