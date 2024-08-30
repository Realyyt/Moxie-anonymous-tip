import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

describe("AnonymousMoxieSender", function () {
  async function deployFixture() {
    // Deploy Moxie token mock, Verifier, and AnonymousMoxieSender
    // ... implementation ...
  }

  describe("Transfers", function () {
    it("Should schedule a transfer", async function () {
      // ... implementation ...
    });

    it("Should verify a valid proof", async function () {
      // ... implementation ...
    });

    it("Should reject an invalid proof", async function () {
      // ... implementation ...
    });

    it("Should allow withdrawal with a valid proof", async function () {
      // ... implementation ...
    });

    // ... more tests ...
  });
});
