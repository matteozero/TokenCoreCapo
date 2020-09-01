//
//  Secp256k1.swift
//  token
//
//  Created by James Chen on 2016/10/26.
//  Copyright © 2016 imToken PTE. LTD. All rights reserved.
//

import Foundation
import secp256k1

extension Encryptor {
    struct SignResult {
        let signature: String // Hex format
        let recid: Int32
    }

    class Secp256k1 {
        static let failureSignResult = SignResult(signature: "", recid: 0)
        private let signatureLength = 64
        private let keyLength = 64

        /// Sign a message with a key and return the result.
        /// - Parameter key: Key in hex format.
        /// - Parameter message: Message in hex format.
        /// - Returns: Signature as a `SignResult`.
        func sign(key: String, message: String) -> SignResult {
            print("prv key: " + key)
            guard let keyBytes = key.tk_dataFromHexString()?.bytes,
                let messageBytes = message.tk_dataFromHexString()?.bytes else {
                return Secp256k1.failureSignResult
            }
            print("messageBytes: " + message)

//      let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_FLAGS_BIT_CONTEXT_VERIFY))!
            var context = secp256k1_context_create(SECP256K1_FLAGS([SECP256K1_FLAGS.SECP256K1_CONTEXT_SIGN, SECP256K1_FLAGS.SECP256K1_CONTEXT_VERIFY]))!
            defer {
                secp256k1_context_destroy(&context)
            }

            if secp256k1_ec_seckey_verify(context, keyBytes) != true {
                return Secp256k1.failureSignResult
            }

            var sig = secp256k1_ecdsa_recoverable_signature()

            if secp256k1_ecdsa_sign_recoverable(context, &sig, messageBytes, keyBytes, nil, nil) == false {
                return Secp256k1.failureSignResult
            }

            let data = Data(count: signatureLength)
            var bytes = [UInt8](data)
            var recid: Int = 0
            _ = secp256k1_ecdsa_recoverable_signature_serialize_compact(context, &bytes, &recid, sig)

//      data.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) in
//        _ = secp256k1_ecdsa_recoverable_signature_serialize_compact(context, bytes, &recid, sig)
//      }

            return SignResult(signature: data.tk_toHexString(), recid: Int32(recid))
        }

        /// Recover public key from signature and message.
        /// - Parameter signature: Signature.
        /// - Parameter message: Raw message before signing.
        /// - Parameter recid: recid.
        /// - Returns: Recoverd public key.
        func recover(signature: String, message: String, recid: Int32) -> String? {
            guard let signBytes = signature.tk_dataFromHexString()?.bytes,
                let messageBytes = message.tk_dataFromHexString()?.bytes else {
                return nil
            }

            var context = secp256k1_context_create(SECP256K1_FLAGS([SECP256K1_FLAGS.SECP256K1_CONTEXT_SIGN, SECP256K1_FLAGS.SECP256K1_CONTEXT_VERIFY]))!
            defer {
                secp256k1_context_destroy(&context)
            }

            var sig = secp256k1_ecdsa_recoverable_signature()
           _ = secp256k1_ecdsa_recoverable_signature_parse_compact(context, &sig, signBytes, Int(recid))

            var publicKey = secp256k1_pubkey()
            var result: Bool = false
            result = secp256k1_ecdsa_recover(context, &publicKey, sig, messageBytes)

            if result == false {
                return nil
            }

            var length = UInt.init(65)
            var data = Data(count: Int(length))
            var bytes = [UInt8](data)
            result = secp256k1_ec_pubkey_serialize(context, &bytes, &length, publicKey, SECP256K1_FLAGS.SECP256K1_EC_UNCOMPRESSED)

//            data.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) in

//                result = secp256k1_ec_pubkey_serialize(context, bytes, &length, &publicKey, UInt32(SECP256K1_EC_UNCOMPRESSED))
//            }

            if result == false {
                return nil
            }

            return data.toHexString()
        }

        /// Verify a key.
        /// - Parameter key: Key in hex format.
        /// - Returns: true if verified, otherwise return false.
        func verify(key: String) -> Bool {
            if key.count != keyLength || !Hex.isHex(key) {
                return false
            }
//            let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_VERIFY))!


            var context = secp256k1_context_create(SECP256K1_FLAGS.SECP256K1_CONTEXT_VERIFY)!
            defer {
                secp256k1_context_destroy(&context)
            }

            if let data = key.tk_dataFromHexString() {
                let bytes = data.bytes
                return bytes.count == 32 && secp256k1_ec_seckey_verify(context, bytes) == true
            } else {
                return false
            }
        }
    }
}
