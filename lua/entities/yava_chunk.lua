AddCSLuaFile()

ENT.Type   = "anim"

function ENT:SetupDataTables()
	self:NetworkVar("Vector",0,"ChunkPos")
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

function ENT:Initialize()
    local chunk_pos = self:GetChunkPos()
    self.correct_mins = yava._offset + chunk_pos*yava._scale*32
    self.correct_maxs = self.correct_mins + Vector(32,32,32)*yava._scale
    self:SetRenderMode(RENDERMODE_NONE) 
end

local count = 0
function ENT:SetupCollisions(soup)
    --print("creating")
    local old_physobj = self:GetPhysicsObject()
    if IsValid(old_physobj) then
        self:SetCollisionGroup(COLLISION_GROUP_WORLD)
        old_physobj:EnableCollisions(false)
        old_physobj:RecheckCollisionFilter()
        --old_physobj:OutputDebugInfo()
    end

    self:PhysicsFromMesh(soup) -- CRASH HERE!
    self:GetPhysicsObject():EnableMotion(false)

    self:EnableCustomCollisions(true)
    
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)

    self:SetCollisionGroup(COLLISION_GROUP_NONE)

    count = count + 1
    --print("created",count)
end

--[[function ENT:TestCollision() 
    if SERVER then
        print("!!!",self:GetCollisionBounds())
    end
end]]

function ENT:Think()
    if CLIENT and not self.setup then
        local chunk_pos = self:GetChunkPos()        
        local chunk = yava._chunks[yava._chunkKey(chunk_pos.x,chunk_pos.y,chunk_pos.z)]
        if chunk then
            chunk.collider_ent = self
            if chunk.fresh_collider_soup then
                self:SetupCollisions(chunk.fresh_collider_soup)
                chunk.fresh_collider_soup = nil
            end
            self.setup = true
        end
    end

    self:SetCollisionBounds(self.correct_mins, self.correct_maxs)
end

function ENT:Draw()
    -- should never be called
end