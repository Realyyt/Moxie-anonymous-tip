import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const AnonymousMoxieSenderModule = buildModule("AnonymousMoxieSenderModule", (m) => {
  const moxieTokenAddress = m.getParameter("moxieTokenAddress");

  const verifier = m.contract("Verifier");
  const anonymousMoxieSender = m.contract("AnonymousMoxieSender", [moxieTokenAddress, verifier]);

  return { verifier, anonymousMoxieSender };
});

export default AnonymousMoxieSenderModule;