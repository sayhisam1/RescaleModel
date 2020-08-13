local module = {}

function module.RescaleModel(model, scale)
    assert(model:IsA("Model") and model.PrimaryPart, "You must pass a model with primary part set to rescale!")
    local descendants = model:GetDescendants()
    local parts, positions, sizes = {}, {}, {}
	local toUnanchor = {}
	local motor6DTargets = {}
	for _, v in pairs(descendants) do
        if v:IsA("BasePart") then
            parts[#parts + 1] = v
            positions[#positions + 1] = v.Position
			            sizes[#sizes + 1] = v.Size
			if not v.Anchored then
				toUnanchor[#toUnanchor + 1] = v
				v.Anchored = true
			end
		elseif v:IsA("Motor6D") then
			motor6DTargets[#motor6DTargets + 1] = {
				Part0 = v.Part0,
				Part1 = v.Part1,
				Parent = v.Parent,
				Name = v.Name,
			}
			v:Destroy()
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
	for _, target in pairs(motor6DTargets) do
		local newMotor = Instance.new("Motor6D")
		newMotor.Part0 = target.Part0
		newMotor.Part1 = target.Part1
		newMotor.C0 = target.Part0.CFrame:ToObjectSpace(target.Part1.CFrame)
		newMotor.Name = target.Name
		newMotor.Parent = target.Parent
	end
	for _, v in pairs(toUnanchor) do
		v.Anchored = false
	end
end

return module