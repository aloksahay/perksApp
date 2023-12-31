# perksApp
Perks iOS app, built for ETHGlobal Online 2023

# Account Abstraction

We used [UniPass](https://docs.wallet.unipass.id/custom-auth/ios-sdk/quick-start) to create or import a SmartAccount. For our example we imported an account which created a SmartAccount which can be used for making future requests, such as signing messages and creating EIP712 Signature's for the Push SDK. It also allows for easily switching between chains. We utilised this so that users can easily create a safe abstracted account whilst also being able to login through their socials for easier adoption.

Creating smart account:
```
let keyStorage = EthereumKeyLocalStorage()
let account = try! EthereumAccount.importAccount(replacing: keyStorage, privateKey: "0xd5071223dcbf1cb824090bd98e0ddc807be00f1874fdd74bbd9225773a824397", keystorePassword: "MY_PASSWORD") //We are aware the pvt is visible, it's all according to bad but intentional design choices.
let options = SmartAccountOptions(masterKeySigner: account, appId: "9e145ea3e5525ee793f39027646c4511",  chainOptions: [ChainOptions(chainId: ChainID.POLYGON_MUMBAI, rpcUrl: "https://node.wallet.unipass.id/polygon-mumbai", relayerUrl: nil), ChainOptions(chainId: ChainID.ETHEREUM_GOERLI, rpcUrl: "https://node.wallet.unipass.id/eth-goerli", relayerUrl: "https://testnet.wallet.unipass.id/relayer-v2-eth")])
self.smartAccount = CustomAuthSdk.SmartAccount(options: options)
let initOptions = SmartAccountInitOptions(chainId: ChainID.POLYGON_MUMBAI)
try! await self.smartAccount!.initialize(options: initOptions)
```

Switching chains from Polygon Mumbai to Eth Goerli:
```
try! self.smartAccount!.switchChain(chainID: ChainID.ETHEREUM_GOERLI)
```

# Deployed contracts

## Polygon Mumbai

```
usdcToken: 0x4198467842C864A044F6F563bca85Aa2F5Aa4d42
perksToken: 0x703E5426AC4D12Fa49bb8B1d0cf3409Ad6eC102e
perksNFT: 0x1A813362a95401832D02d8d3B3dA292929b8d395
6551 registry: 0x67AE575E274f9176D8e4F864185b830768E7A96d
6551 accountImpl: 0x9929711aC11528B9D42f762ed59a5F1450E91fd2
perksVault: 0x52d916328330c88A00284ee51b9f5FECc688A072
owner of perksNFT #1: 0xA0066f1949636FB62f6cEC693Eec4A5C3531d791
token bound account of NFT #1: 0x1606538dFdB85E85560A0705AC3b8AF2Ba7a7350
StoreNFTFactory: 0xDeA5D42E74D777b97D762D3Edf8EcaF67ef4959C

Apecoin NFT: 0xAe9966B63a180F659D51147eaD7398edBEd5E2aF
Tacobell NFT: 0xDD4634704E1f9a90c295355B7D03b8b3d9B2f235

Uniswap Hook: 0x086C62046fD044d62AFfd14CE8e50232Cd1Aa74F
```

## Scroll Sepolia

```
usdcToken: 0xa0D8EC511910b6d2732AfBe93674F7c8A5FeF709
perksToken: 0x6a825b052D751562d988a6b30F1685E828B04b68
perksNFT: 0xb4F3c8F7fa521B253AFcE5259b1e3833d8f65B36
6551 registry: 0x6f5756Ce3047Cc216c8582B1379E1DD117d720B1
6551 accountImpl: 0x198Bd08EcA211Dd56eaE444E6f0eA5F87674f0D4
perksVault: 0x20BE6670d018D88B25dfB76c5460455bFBa6182a
owner of perksNFT #1: 0xA0066f1949636FB62f6cEC693Eec4A5C3531d791
token bound account of NFT #1: 0x64BFb98af28e9E76AFb77Fa46E0ab5f28034Ebf2
StoreNFTFactory: 0xBdd032549b746Ca176b1Df9716433CDD259d2223
Apecoin NFT: 0x1CcF28d9cF59a63C4661b50bA68eDA9eA76708Da
Tacobell NFT: 0x4520FC2D273c149DAD9307650e1d95DeEB26e907
```

## Mantle testnet

Tweet link: https://x.com/sahay_alok/status/1716230030362132906

```
usdcToken: 0xD46A99587C3Aa2A4e2fe1F0EE75495Dd38Caa2bA
perksToken: 0x8078cB27dD51266950FE0317CB314F16f11Fac8b
perksNFT: 0xA2009709CBcE4a38f816f7190df4D06345A9f6aC
6551 registry: 0x07B48B11F2493D108d9ebbF8A684d00f72EAcFd5
6551 accountImpl: 0x4a4e97E89e63438811f7646E7802300d5Fd4Bb3F
perksVault: 0xB93f2Ce120B7611a785142F569c5905E018EaabF
owner of perksNFT #1: 0xA0066f1949636FB62f6cEC693Eec4A5C3531d791
token bound account of NFT #1: 0x568DdeAa031638F601CFb6b49897ddE99eE40aE1
StoreNFTFactory: 0xC27Ca4fCAe6B0D3dE120f0C577d7724f992a6E81
Apecoin NFT: 0x339bAD52BB7874489567ae1208537FaeA8892993
Tacobell NFT: 0x82cCE60CC416e4d3C8f3A9868512fdeB706A597B
```

## Ethereum Sepolia

```
usdcToken: 0xaD6CD743a19EE2f7F6D43d9b7E7eA398f05BCD15
perksToken: 0x070b65b46Ae3E1Ed71fcCE77223689E8e22384F0
perksNFT: 0x7E04c9d2a324d94292CF3C96ebf597a57c528d6d
6551 registry: 0xcb78b522fe8dE756e2bE39A448c589a372FBE7B7
6551 accountImpl: 0xFfed3aC0D909bd7DCfeA71a577ffd6B7fEbb991e
perksVault: 0xCCA3515A0f645344f1d48ADCe96035976b4C23E3
owner of perksNFT #1: 0xA0066f1949636FB62f6cEC693Eec4A5C3531d791
token bound account of NFT #1: 0x516B893fdCA791C85a30e2ce9425D0ef8DC7AAa1
StoreNFTFactory: 0xbcaa140757526562AF99a4bd1a4A7739223bcD8d
Apecoin NFT: 0x7f343A9Ddc934069B9d3bD7E50535c6a55eC20c9
Tacobell NFT: 0xFc58aB02A7b4A78Ca29BD3f8D7168a802966639F
```
