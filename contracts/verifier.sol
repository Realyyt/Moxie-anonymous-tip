// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Verifier {
    using Pairing for *;

    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] ic;
    }

    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }

    VerifyingKey verifyingKey;

    constructor(VerifyingKey memory _vk) {
        verifyingKey = _vk;
    }

    function verifyProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[2] memory input
    ) public view returns (bool) {
        Proof memory proof;
        proof.a = Pairing.G1Point(a[0], a[1]);
        proof.b = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.c = Pairing.G1Point(c[0], c[1]);

        require(input.length + 1 == verifyingKey.ic.length, "Invalid input length");

        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(verifyingKey.ic[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, verifyingKey.ic[0]);

        // Pairing check
        if (!Pairing.pairingProd4(
            proof.a, proof.b,
            Pairing.negate(vk_x), verifyingKey.gamma,
            Pairing.negate(proof.c), verifyingKey.delta,
            Pairing.negate(verifyingKey.alpha), verifyingKey.beta
        )) return false;

        return true;
    }
}

library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }

    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }

    // Field modulus
    uint256 constant FIELD_MODULUS = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Curve order
    uint256 constant CURVE_ORDER = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    function pairingProd4(
        G1Point memory a1, G2Point memory a2,
        G1Point memory b1, G2Point memory b2,
        G1Point memory c1, G2Point memory c2,
        G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }

    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint256[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0x80, r, 0x40)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success, "EC addition failed");
    }

    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint256[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x60, r, 0x40)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success, "EC scalar multiplication failed");
    }

    function negate(G1Point memory p) internal pure returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        if (p.Y == 0) {
            return G1Point(0, 0);
        } else {
            return G1Point(p.X, FIELD_MODULUS - (p.Y % FIELD_MODULUS));
        }
    }

    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length, "Pairing lengths don't match");
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);

        for (uint i = 0; i < elements; i++) {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }

        uint[1] memory out;
        bool success;

        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }

        require(success, "Pairing check failed");

        return out[0] != 0;
    }
}