using Godot;
using System;

public partial class Player : CharacterBody3D
{
	[Signal]
	public delegate void HitEventHandler();

	public int Speed { get; set; } = 14;
	[Export] public int FallAcceleration { get; set; } = 75;
	
	[Export]
	public int JumpImpulse { get; set; } = 20;

	[Export]
	public int BounceImpulse { get; set; } 

	private Vector3 _targetVelocity = Vector3.Zero;

	public override void _PhysicsProcess(double delta)
	{
		
		var direction = Vector3.Zero;

		if (Input.IsActionPressed("move_right"))
		{
			direction.X += 1.0f;
		}
		if (Input.IsActionPressed("move_left"))
		{
			direction.X -= 1.0f;
		}
		if (Input.IsActionPressed("move_forward"))
		{
			direction.Z -= 1.0f;
		}
		if (Input.IsActionPressed("move_back"))
		{
			direction.Z += 1.0f;
		}

		var animPlayer = GetNode<AnimationPlayer>("AnimationPlayer");

		if (direction != Vector3.Zero)
		{
			direction = direction.Normalized();
			GetNode<Node3D>("Pivot").Basis = Basis.LookingAt(direction);
			animPlayer.SpeedScale = 2.0f;
		}
		else
		{
			animPlayer.SpeedScale = 1.0f; 
		}

		_targetVelocity.X = direction.X * Speed;
		_targetVelocity.Z = direction.Z * Speed;
		
		if (!IsOnFloor())
		{
			_targetVelocity.Y -= FallAcceleration * (float)delta;
		}
		
		if (IsOnFloor() && Input.IsActionJustPressed("jump"))
		{
			_targetVelocity.Y = JumpImpulse;
		}

		Velocity = _targetVelocity;
		MoveAndSlide();
		
	  for (int index = 0; index < GetSlideCollisionCount(); index++)
		{
			KinematicCollision3D collision = GetSlideCollision(index);

			if (collision.GetCollider() is Mob mob)
			{
				if (Vector3.Up.Dot(collision.GetNormal()) > 0.1f)
				{
					mob.Squash();
					_targetVelocity.Y = BounceImpulse;
					break;
				}
			}
		}
		
		var pivot = GetNode<Node3D>("Pivot");
		pivot.Rotation = new Vector3(Mathf.Pi / 6.0f * Velocity.Y / JumpImpulse, pivot.Rotation.Y, pivot.Rotation.Z);
	}
	
	private void _on_mob_detector_body_entered(Node3D body)
	{
		Die();
	}
	
	private void Die()
	{
		GetNode<Timer>("/root/Main/MobTimer").Stop();
		EmitSignal("Hit");
		QueueFree();
	}
	
	
	private void _on_player_hit()
	{
		GetNode<Timer>("/root/Main/MobTimer").Stop();
		GetNodeOrNull<Control>("/root/Main/UserInterface/Retry").Show();

	}
		
	public override void _Ready()
	{
		Connect("Hit", new Callable(this, nameof(_on_player_hit)));
		GetNode<AnimationPlayer>("AnimationPlayer").Play("float"); 
	}

}
