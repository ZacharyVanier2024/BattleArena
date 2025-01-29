-- https://zap.redblox.dev/playground.html

--[[

event Input = {
    from: Client,
    type: Unreliable,
    call: ManyAsync,
    data: struct {
        foo: string,
        bar: u8,
    }
}

event WeaponChange = {
    from: Client,
    type: Unreliable,
    call: ManyAsync,
    data: struct {
        toolName: string,
        Equipped: boolean,
    }
}

event CombatSwing = {
    from: Server,
    type: Unreliable,
    call: ManyAsync,
    data: struct {
        playerId: i32,
        attackName: string,
        weaponName: string,
        side: string,
    }
}

event CombatImpact = {
    from: Server,
    type: Unreliable,
    call: ManyAsync,
    data: struct {
        attackerId: i32,
        victimId: i32,
        victimModel: string,
        attackName: string,
        weaponName: string,
        hitPartName: string,
        hitX: i32,
        hitY: i32,
        hitZ: i32,
    }
}

event ApplyKnockback = {
    from: Server,
    type: Unreliable,
    call: ManyAsync,
    data: struct {
        targetId: i32,
        targetModel: string,
        directionX: i32,
        directionY: i32,
        directionZ: i32,
        force: i32,
        duration: i32,
        verticalForce: i32,
        isCasterAdvance: boolean,
        attackName: string,
    }
}

event SpaceBarHeld = {
    from: Client,
    type: Unreliable,
    call: ManyAsync,
    data: struct {
        held: boolean,
    }
}

event Air3Knockback = {
    from: Server,
    type: Unreliable,
    call: ManyAsync,
    data: struct {
        attackerId: i32,
        targetId: i32,
        targetModel: string,
        attackerX: i32,
        attackerY: i32,
        attackerZ: i32,
    }
}

event ResetNetworkOwnership = {
    from: Client,
    type: Reliable,
    call: OneAsync,
    data: struct {
        targetId: i32,
        targetModel: string,
    }
}

]]