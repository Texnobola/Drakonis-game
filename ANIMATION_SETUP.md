# Animation Setup Guide

## Follow These Steps in Godot:

### Step 1: Open UAL2.glb
1. In FileSystem, double-click `UAL2.glb`
2. This opens the GLB file in the scene viewer

### Step 2: Select Skeleton3D
1. In the Scene tree (top right), find and click on `Skeleton3D`
2. It should be under: Scene → Armature → Skeleton3D

### Step 3: Create BoneMap
1. With Skeleton3D selected, look at the Import panel (right side)
2. Find "Retarget" section
3. Click on `<empty>` next to "Bone Map"
4. Click "New BoneMap" button

### Step 4: Create SkeletonProfile
1. Still in Import panel, find "Profile" dropdown
2. Click on `<empty>`
3. Click "New SkeletonProfileHumanoid"
4. This maps the bones to Godot's humanoid skeleton

### Step 5: Reimport
1. At the bottom of the Import panel, click "Reimport"
2. Wait for Godot to process (may take a few seconds)

### Step 6: Use the Character
Now you can:
- Drag UAL2.glb into your scene as a player model
- The animations will work properly with the skeleton
- Attach player.gd script to control it

## Available Animations in UAL2:
- Idle, Walk, Run
- Jump, Fall, Land
- Crouch variations
- And many more!

Check the AnimationPlayer node to see all available animations.
