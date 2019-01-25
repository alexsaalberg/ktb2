
--[[
		if angle > angleThreshold then


		local a

	local modifier = 25 -- seconds

	local maxDelta = 50 -- above 50 pixels, won't go faster
	if deltaX > maxDelta then
		deltaX = maxDelta
	end
	if deltaY > maxDelta then
		deltaY = maxDelta
	end

	self.body:applyLinearImpulse(modifier * deltaX * dt, modifier * deltaY * dt)
]]


		print("mouse is down")
		local x, y = self.body:getPosition()
		local mx, my = love.mouse:getPosition()
		local vx, vy = self.body:getLinearVelocity()

		-- move towards the mouse
		local tmx, tmy = mx - x, my - y -- vector TOWARDS mouse (deltaX/Y)
		--vx, vy, _ = ExtraMath.normalize(vx, vy)
		--tmx, tmy, _ = ExtraMath.normalize(tmx, tmy)

		-- degree angle between 
		--self.angle = ExtraMath.degAngle(tmx, tmy, vx, vy)
		--local angle = self.angle
		local vAngle = ExtraMath.degAngle(vx, vy)
		local tmAngle = ExtraMath.degAngle(tmx, tmy)

		-- angle of vector from velocity vector towards mouse vector
		local angleDifference = ExtraMath.degAngle(tmx - vx, tmy - vy)
		angleDifference = tmAngle - vAngle --angle from velocity towards mouse
		angleDifference = (angleDifference + 360) % 360
		local angleThreshold = 20
		
		local velocity = ExtraMath.magnitude(vx, vy) -- magnitude of velocity
		local velocityThreshold = 40

		local fx, fy = 0, 0 -- eventual force unit vector

		print("vx="..vx.."\tvy="..vy)

		if velocity < velocityThreshold then
			-- if velocity is very low, just move towards mouse
			fx, fy = tmx, tmy
		elseif (math.abs(angleDifference) < angleThreshold) then
			-- elseif angle is pretty low, just move towards mouse
			fx, fy = tmx, tmy
		elseif math.abs(angleDifference) < 120.0 then
			-- elseif angle is higher, but wolf is kinda moving towards mouse, turn towards mouse a little
			local forceAngle = 0.0
			if(angleDifference < 180.0) then
				forceAngle = angleDifference + (angleDifference / 2)
			else
				forceAngle = angleDifference + ((angleDifference - 360.0) / 2)
			end
			fx, fy = math.cos(forceAngle), math.sin(forceAngle)
		else
			-- if angle is very high, just slow down
			fx, fy = -vx, -vy
		end
		--[[

		-- if velocity is too high, apply force directly opposite velocity (slow down)
		if velocity > velocityThreshold then
			fx, fy = -vx, -vy
		-- if velocity is low enough, move towards mouse
			print("v too high")
		else
			print("velocity is low enough")
			-- if angle is very high, overcompensate a little (so wolf is angled more towards mouse)
			if math.abs(angleDifference) > angleThreshold then
				forceAngle = angleDifference - (angleDifference/2)
				fx, fy = math.cos(forceAngle), math.sin(forceAngle)
			-- if angle is low enough, apply force directly TOWARDS mouse
				print("angle too high")
			else
				fx, fy = tmx, tmy
				print('angle low enough')
			end
		end
		]]
		print("angleDiff="..angleDifference.."\tvelocity="..velocity)
		print("vAngle="..vAngle.."\ttmAngle="..tmAngle)
		print("fx="..fx.."\tfy="..fy.."\tfAngle="..ExtraMath.degAngle(fx, fy)..'\tforceAngle='..(forceAngle or 0))


		local speed = 100
		fx, fy = ExtraMath.normalize(fx, fy)
		fx, fy = speed * fx, speed * fy
		print("fx="..fx.."\tfy="..fy.."\tfAngle="..ExtraMath.degAngle(fx, fy)..'\tforceAngle='..(forceAngle or 0))

		self.body:applyLinearImpulse(fx * dt, fy * dt)