# Drakonis - Enhanced Player Controller

## New Features Implemented

### 1. SPRINT & CROUCH
- **Sprint**: Double-tap W to toggle sprint (8.0 speed vs 5.0 walk speed)
- **Crouch**: Hold Ctrl to crouch (reduces height by 50%, slower movement at 2.5 speed)
- **FOV Effects**: Camera FOV increases when sprinting, decreases when crouching
- **Ceiling Detection**: Can't stand up if there's something above you

### 2. DOUBLE JUMP & AIR DASH
- **Double Jump**: Press Space again while in the air for a second jump
- **Air Dash**: Press E while airborne to dash in movement direction (or forward if not moving)
- Both abilities reset when landing on the ground

### 3. FOOTSTEP SOUNDS
- Procedural footstep audio that plays while moving
- Speed-based timing: Faster when sprinting, slower when crouching
- Random pitch variation for more natural sound
- Only plays when on the ground and moving

### 4. BETTER PLAYER MODEL
- Replaced simple capsule with a body + head model
- Blue colored character (easy to see)
- Body scales properly when crouching
- Collision shape adjusts dynamically

### 5. CHECKPOINT SYSTEM
- 3 checkpoints placed around the level
- Walk through a checkpoint to activate it (turns green and glows)
- Fall off the map? Respawn at last checkpoint
- Death zone at Y = -10 triggers respawn
- CheckpointManager singleton tracks progress

## Controls

### Movement
- **W/A/S/D** - Move (camera-relative)
- **Double-tap W** - Toggle Sprint
- **Ctrl** - Crouch
- **Space** - Jump / Double Jump
- **E** - Air Dash (while airborne)

### Camera
- **Mouse** - Look around
- **ESC** - Toggle mouse lock/unlock

## Technical Details

### Files Created/Modified
1. `player.gd` - Enhanced with all new movement features
2. `checkpoint.gd` - Checkpoint activation and visual feedback
3. `checkpoint_manager.gd` - Global checkpoint system (autoload)
4. `footstep_audio.gd` - Procedural footstep sound generator
5. `main.tscn` - Updated scene with checkpoints and better player model
6. `project.godot` - Added new input actions and autoload

### New Input Actions
- `crouch` - Ctrl key
- `air_dash` - E key

Note: Sprint is activated by double-tapping the `move_forward` (W) key within 0.3 seconds.

### Player Stats
- Walk Speed: 5.0
- Sprint Speed: 8.0
- Crouch Speed: 2.5
- Jump Velocity: 4.5
- Double Jump Velocity: 4.0
- Air Dash Speed: 15.0
- Mouse Sensitivity: 0.003

## How to Test

### Running the Game:
1. **Open Godot** and load the Drakonis project
2. **Press F5** to run
3. Try all the movement abilities!
4. Walk through checkpoints to activate them
5. Jump off the edge to test respawn system

### Optional - Improve Character Animations:
The game uses UAL1_Standard.glb character model. For better animation support:
1. **In FileSystem**, double-click `UAL1_Standard.glb`
2. **In Scene tree** (top-right), click on `Skeleton3D` (under Armature)
3. **In Import panel** (right side):
   - Find "Retarget" → "Bone Map" → click `<empty>`
   - Click "New BoneMap"
   - Find "Profile" → click `<empty>`  
   - Click "New SkeletonProfileHumanoid"
4. **Click "Reimport"** at bottom of Import panel
5. This enables proper animation retargeting

## Next Steps

You can now add:
- Real footstep sound files (replace procedural audio)
- Better 3D character model (import .glb/.gltf)
- Stamina system to limit sprint/dash
- Animation for crouch/jump/dash
- More checkpoints throughout your level
- Visual effects for air dash
- Sound effects for checkpoint activation

Enjoy your enhanced movement system! 🎮
