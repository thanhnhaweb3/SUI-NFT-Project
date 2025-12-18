module music_copyright::copyright;

use std::vector;
use sui::clock::{Self as clock, Clock};
use sui::event;
use sui::object::{Self as object, ID, UID};
use sui::transfer;
use sui::tx_context::TxContext;

/// On-chain proof of ownership for a music work.
/// Stores hash + IPFS CID; the actual media stays off-chain.
public struct MusicCopyright has key, store {
    id: UID,
    /// Author wallet at registration time
    author: address,
    /// SHA-256 hash (or other digest) of the work bytes
    work_hash: vector<u8>,
    /// IPFS content identifier where the file/lyrics is stored
    ipfs_cid: vector<u8>,
    /// Registration timestamp (ms) taken from the on-chain clock
    registered_at_ms: u64,
}

/// Emitted when a new copyright object is registered.
public struct Registered has copy, drop {
    object_id: ID,
    author: address,
    registered_at_ms: u64,
}

/// Emitted when ownership is transferred.
public struct Transferred has copy, drop {
    object_id: ID,
    from: address,
    to: address,
}

/// Register a new music copyright.
/// - `work_hash`: SHA-256 digest of the content (off-chain)
/// - `ipfs_cid`: CID of the content stored on IPFS
/// Requires the global `Clock` to get an on-chain timestamp.
public entry fun register(
    work_hash: vector<u8>,
    ipfs_cid: vector<u8>,
    clock: &Clock,
    ctx: &mut TxContext,
) {
    let ts = clock::timestamp_ms(clock);
    let author = ctx.sender();
    let mc = MusicCopyright {
        id: object::new(ctx),
        author,
        work_hash,
        ipfs_cid,
        registered_at_ms: ts,
    };

    event::emit(Registered {
        object_id: object::id(&mc),
        author,
        registered_at_ms: ts,
    });

    transfer::public_transfer(mc, author);
}

/// Transfer ownership of an existing copyright object to `recipient`.
public entry fun transfer_rights(mc: MusicCopyright, recipient: address, ctx: &TxContext) {
    let from = ctx.sender();
    event::emit(Transferred {
        object_id: object::id(&mc),
        from,
        to: recipient,
    });

    transfer::public_transfer(mc, recipient);
}

