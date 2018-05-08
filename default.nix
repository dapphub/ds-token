{ solidityPackage, dappsys }: solidityPackage {
  name = "ds-token";
  deps = with dappsys; [ds-math ds-stop ds-test erc20];
  src = ./src;
}
