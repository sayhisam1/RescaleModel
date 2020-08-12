local module = {}

function module.RescaleModel(model, scale)
    assert(model:IsA("Model") and model.PrimaryPart, "You must pass a model with primary part set to rescale!")
    local descendants = model:GetDescendants()
    local parts, positions, sizes = {}, {}, {}
    for _, v in pairs(descendants) do
        if v:IsA("BasePart") then
            parts[#parts + 1] = v
            positions[#positions + 1] = v.Position
            sizes[#sizes + 1] = v.Size
        end
    end

    local objectPositions = {model.PrimaryPart.CFrame:PointToObjectSpace(unpack(positions))}
    local scaleMatrix = CFrame.new(0, 0, 0, scale, 0, 0, 0, scale, 0, 0, 0, scale)
    local primaryCf = model.PrimaryPart.CFrame * scaleMatrix
    local newPoints = {primaryCf:PointToWorldSpace(unpack(objectPositions))}
    local newSizes = {scaleMatrix:PointToWorldSpace(unpack(sizes))}

    local newCframes = {}
    for i, v in ipairs(parts) do
        parts[i].Size = newSizes[i]
        newCframes[i] = parts[i].CFrame - parts[i].CFrame.Position + newPoints[i]
    end
    game.Workspace:BulkMoveTo(parts, newCframes)
end

return module