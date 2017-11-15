dapp: with dapp; solidityPackage {
  name = "ds-token";
  deps = with dappsys; [erc20 ds-math ds-stop ds-test];
  src = ./src;
}
