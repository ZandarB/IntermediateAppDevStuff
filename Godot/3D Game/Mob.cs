using Godot;
using System;

[Signal]
public delegate void SquashedEventHandler();

public partial class Mob : CharacterBody3D
{
	[Signal]
	public delegate void SquashedEventHandler();
	
	[Export]
	public int MinSpeed {get; set; } = 10;

	[Export]
	public int MaxSpeed { get; set; } = 18;

	public override void _PhysicsProcess(double delta)
	{
		MoveAndSlide();
	}
	
	public void Initialize(Vector3 startPosition, Vector3 playerPosition)
	{
		LookAtFromPosition(startPosition, playerPosition, Vector3.Up);
		RotateY((float)GD.RandRange(-Mathf.Pi / 4.0, Math.PI / 4.0));
		
		int randomSpeed = GD.RandRange(MinSpeed, MaxSpeed);
		
		Velocity = Vector3.Forward * randomSpeed;
		
		Velocity = Velocity.Rotated(Vector3.Up, Rotation.Y);
		
		GetNode<AnimationPlayer>("AnimationPlayer").SpeedScale = randomSpeed / MinSpeed;
	}
	
	private void _on_visible_on_screen_notifier_3d_screen_exited()
	{
		QueueFree();
	}
	
	public void Squash()
	{
		EmitSignal("Squashed");
		QueueFree();
	}
	
	public override void _Ready()
	{
		GetNode<AnimationPlayer>("AnimationPlayer").Play("float"); 
	}
	
}
