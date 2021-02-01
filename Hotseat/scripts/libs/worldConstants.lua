
--------------------------------------------
-- World Constants v.1.3 - code library
--------------------------------------------
-- provides functions for setting/resetting
-- projectile/charge speed,
-- artillery/leap height,
-- gravity (strange results)
--------------------------------------------
--------------------------------------------
-- NOTE:
-- changing any constant, will affect every
-- weapon in the game.
-- to play nice with other mods, it is
-- important to reset them after each use.
--
-- to apply a new value to your weapon,
-- follow this simple checklist:
--
---------------------------------
-- 1. set the constant
-- 2. AddProjectile(.. NO_DELAY)
-- 3. reset constant
---------------------------------
--
-- always use NO_DELAY between setting and
-- resetting to ensure it all happens in a
-- single cycle.
--
--------------------------------------------
--------------------------------------------

-------------------
-- initialization:
-------------------

-- local worldConstants = require(self.scriptPath ..'worldConstants')


--------------------------------------------------------
-- function list:
--------------------------------------------------------
-- every constant we can change has functions
-- associated with them that follows the same pattern.
-- I've documented the functions for the Speed constant.
-- reference these functions for parameter use
-- of the remaining constants.
--------------------------------------------------------


----------------------------------- CONSTANT: SPEED ------------------------------------
----------------------------------------------------------------------------------------
-- projectile/charge speed.
----------------------------

----------------------------------------------------------------------------------------
-- worldConstants.SetSpeed(effect, value, isQueued)
----------------------------------------------------------------------------------------
-- sets projectile/charge speed to 'value'
--
-- arg      - type        - description
-- ------     -----------   ------------------------------------------------------------
-- effect   - SkillEffect - effect object modifying the constants.
-- value    - number      - value to set the constant to.
-- isQueued - boolean     - if the constant change should be queued. defaults to false.
----------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------
-- worldConstants.ResetSpeed(effect, value, isQueued)
----------------------------------------------------------------------------------------
-- resets projectile/charge speed
--
-- arg      - type        - description
-- ------     -----------   ------------------------------------------------------------
-- effect   - SkillEffect - effect object modifying the constants.
-- value    - number      - value to set the constant to.
-- isQueued - boolean     - if the constant change should be queued. defaults to false.
----------------------------------------------------------------------------------------

-- worldConstants.QueuedSetSpeed(effect, value)		-> calls set function with isQueued = true
-- worldConstants.QueuedResetSpeed(effect, value)	-> calls set function with isQueued = true

-------------------------------------------------------
-- worldConstants.GetDefaultSpeed()
-------------------------------------------------------
-- returns the game's default projectile/charge speed.
-------------------------------------------------------



----------------------------------- CONSTANT: HEIGHT -----------------------------------
----------------------------------------------------------------------------------------
-- artillery/leap height:
-- default = 18
-----------------------------------------------

-- worldConstants.SetHeight(...)
-- worldConstants.ResetHeight(...)
-- worldConstants.QueuedSetHeight(...)
-- worldConstants.QueuedResetHeight(...)
-- worldConstants.GetDefaultHeight(...)
-----------------------------------------------


----------------------------------- CONSTANT: GRAVITY ----------------------------------
----------------------------------------------------------------------------------------
-- affects artillery in strange ways.
-- default = 3
-----------------------------------------------

-- worldConstants.SetGravity(...)
-- worldConstants.ResetGravity(...)
-- worldConstants.QueuedSetGravity(...)
-- worldConstants.QueuedResetGravity(...)
-- worldConstants.GetDefaultGravity(...)
-----------------------------------------------


------------------------------- CONSTANT: LASER DURATION -------------------------------
----------------------------------------------------------------------------------------
-- the duration of a laser shot.
-- default = 0.5
-----------------------------------------------

-- worldConstants.SetLaserDuration(...)
-- worldConstants.ResetLaserDuration(...)
-- worldConstants.QueuedSetLaserDuration(...)
-- worldConstants.QueuedResetLaserDuration(...)
-- worldConstants.GetDefaultLaserDuration(...)
-----------------------------------------------


----------------------------------------------------------------
----------------------------------------------------------------

local default = {}
local this = {}

-- sets up all functions for a certain constant.
function this.AddConstant(name, const)
	assert(type(name) == 'string')
	assert(type(const) == 'string')
	
	default[const] = Values[const]
	this["GetDefault".. name] = function() return default[const] end
	
	this["Set".. name] = function(effect, value, isQueued)
		assert(type(value) == 'number')
		assert(not isQueued or type(isQueued) == 'boolean')
		
		isQueued = isQueued and "Queued" or ""
		effect["Add".. isQueued .."Script"](effect, "Values.".. const .."=".. value)
	end
	
	this["Reset".. name] = function(effect, isQueued)
		assert(not isQueued or type(isQueued) == 'boolean')
		
		isQueued = isQueued and "Queued" or ""
		effect["Add".. isQueued .."Script"](effect, "Values.".. const .."=".. default[const])
	end
	
	this["QueuedSet".. name] = function(effect, value) return this["Set".. name](effect, value, true) end
	this["QueuedReset".. name] = function(effect) return this["Reset".. name](effect, true) end
end

this.AddConstant("Speed", "x_velocity")
this.AddConstant("Height", "y_velocity")
this.AddConstant("Gravity", "gravity")
this.AddConstant("LaserDuration", "laser_length")

return this