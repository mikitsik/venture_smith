const hre = require("hardhat");

const REGISTRY_ADDRESS =
  process.env.SOMNIA_REGISTRY_ADDRESS ||
  "0xCea3d6f2AB4Bc3aa87de55f3C5Be84a7aDa02999";

async function main() {
  const [signer] = await hre.ethers.getSigners();

  console.log("Using wallet:", signer.address);
  console.log("Registry:", REGISTRY_ADDRESS);

  const registry = await hre.ethers.getContractAt(
    "VentureSmithRegistry",
    REGISTRY_ADDRESS
  );

  const metadata = {
    title: "GitHub Issue Triage Copilot",
    problem: "Open-source maintainers spend too much time triaging duplicate and low-quality issues.",
    audience: "Open-source maintainers",
    founder_match: {
      background: "Ruby on Rails developer",
      available_days: 30
    },
    evidence: [
      {
        source: "github",
        url: "https://github.com/example/project/issues/123",
        summary: "Maintainers discuss repeated duplicate issue reports."
      }
    ],
    mvp_plan: [
      "Import GitHub issues",
      "Detect duplicates",
      "Suggest labels and replies"
    ]
  };

  const metadataJson = JSON.stringify(metadata);
  const metadataHash = hre.ethers.keccak256(
    hre.ethers.toUtf8Bytes(metadataJson)
  );

  const metadataURI = "rails://opportunities/demo-passport-1";

  console.log("Metadata hash:", metadataHash);
  console.log("Metadata URI:", metadataURI);

  const tx = await registry.createOpportunityPassport(
    metadataHash,
    metadataURI
  );

  console.log("Create tx:", tx.hash);

  const receipt = await tx.wait();

  const event = receipt.logs
    .map((log) => {
      try {
        return registry.interface.parseLog(log);
      } catch (_error) {
        return null;
      }
    })
    .find((parsed) => parsed && parsed.name === "OpportunityPassportCreated");

  if (!event) {
    throw new Error("OpportunityPassportCreated event not found");
  }

  const passportId = event.args.passportId;

  console.log("Passport ID:", passportId.toString());

  const passport = await registry.getOpportunityPassport(passportId);

  console.log("Passport:");
  console.log({
    founder: passport.founder,
    metadataHash: passport.metadataHash,
    score: passport.score.toString(),
    resultHash: passport.resultHash
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
