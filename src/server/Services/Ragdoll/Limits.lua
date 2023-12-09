local RagdollLimit = {}

RagdollLimit.REFERENCE_GRAVITY = workspace.Gravity

RagdollLimit.HEAD_LIMITS = {
	UpperAngle = 30,
	TwistLowerAngle = -45,
	TwistUpperAngle = 45,
	FrictionTorque = 10, -- 400
	ReferenceMass = 1.0249234437943,
}

RagdollLimit.WAIST_LIMITS = {
	UpperAngle = 20,
	TwistLowerAngle = -40,
	TwistUpperAngle = 20,
	FrictionTorque = 100,
	ReferenceMass = 2.861558675766,
}

RagdollLimit.ANKLE_LIMITS = {
	UpperAngle = 10,
	TwistLowerAngle = -10,
	TwistUpperAngle = 10,
	FrictionTorque = 150;
	ReferenceMass = 0.43671694397926,
}

RagdollLimit.ELBOW_LIMITS = {
	UpperAngle = 20,
	TwistLowerAngle = 5,
	TwistUpperAngle = 120,
	FrictionTorque = 200;
	ReferenceMass = 0.70196455717087,
}

RagdollLimit.WRIST_LIMITS = {
	UpperAngle = 30,
	TwistLowerAngle = -10,
	TwistUpperAngle = 10,
	FrictionTorque = 50;
	ReferenceMass = 0.69132566452026,
}

RagdollLimit.KNEE_LIMITS = {
	UpperAngle = 5,
	TwistLowerAngle = -120,
	TwistUpperAngle = -5,
	FrictionTorque = 350;
	ReferenceMass = 0.65389388799667,
}

RagdollLimit.SHOULDER_LIMITS = {
	UpperAngle = 110,
	TwistLowerAngle = -75,
	TwistUpperAngle = 75,
	FrictionTorque = 750,
	ReferenceMass = 1,
}

RagdollLimit.HIP_LIMITS = {
	UpperAngle = 40,
	TwistLowerAngle = -5,
	TwistUpperAngle = 80,
	FrictionTorque = 550,
	ReferenceMass = 1.9175016880035,
}

RagdollLimit.RAGDOLL_RIG = {
	{
		part0Name = "UpperTorso";
		part1Name = "Head";
		attachmentName = "NeckRigAttachment";
		motorParentName = "Head";
		motorName = "Neck";
		limits = RagdollLimit.HEAD_LIMITS;
	};
	{
		part0Name = "LowerTorso";
		part1Name = "UpperTorso";
		attachmentName = "WaistRigAttachment";
		motorParentName = "UpperTorso";
		motorName = "Waist";
		limits = RagdollLimit.WAIST_LIMITS;
	};
	{
		part0Name = "UpperTorso";
		part1Name = "LeftUpperArm";
		attachmentName = "LeftShoulderRagdollAttachment";
		motorParentName = "LeftUpperArm";
		motorName = "LeftShoulder";
		limits = RagdollLimit.SHOULDER_LIMITS;
	};
	{
		part0Name = "LeftUpperArm";
		part1Name = "LeftLowerArm";
		attachmentName = "LeftElbowRigAttachment";
		motorParentName = "LeftLowerArm";
		motorName = "LeftElbow";
		limits = RagdollLimit.ELBOW_LIMITS;
	};
	{
		part0Name = "LeftLowerArm";
		part1Name = "LeftHand";
		attachmentName = "LeftWristRigAttachment";
		motorParentName = "LeftHand";
		motorName = "LeftWrist";
		limits = RagdollLimit.WRIST_LIMITS;
	};
	{
		part0Name = "UpperTorso";
		part1Name = "RightUpperArm";
		attachmentName = "RightShoulderRagdollAttachment";
		motorParentName = "RightUpperArm";
		motorName = "RightShoulder";
		limits = RagdollLimit.SHOULDER_LIMITS;
	};
	{
		part0Name = "RightUpperArm";
		part1Name = "RightLowerArm";
		attachmentName = "RightElbowRigAttachment";
		motorParentName = "RightLowerArm";
		motorName = "RightElbow";
		limits = RagdollLimit.ELBOW_LIMITS;
	};
	{
		part0Name = "RightLowerArm";
		part1Name = "RightHand";
		attachmentName = "RightWristRigAttachment";
		motorParentName = "RightHand";
		motorName = "RightWrist";
		limits = RagdollLimit.WRIST_LIMITS;
	};

	{
		part0Name = "LowerTorso";
		part1Name = "LeftUpperLeg";
		attachmentName = "LeftHipRigAttachment";
		motorParentName = "LeftUpperLeg";
		motorName = "LeftHip";
		limits = RagdollLimit.HIP_LIMITS;
	};
	{
		part0Name = "LeftUpperLeg";
		part1Name = "LeftLowerLeg";
		attachmentName = "LeftKneeRigAttachment";
		motorParentName = "LeftLowerLeg";
		motorName = "LeftKnee";
		limits = RagdollLimit.KNEE_LIMITS;
	};
	{
		part0Name = "LeftLowerLeg";
		part1Name = "LeftFoot";
		attachmentName = "LeftAnkleRigAttachment";
		motorParentName = "LeftFoot";
		motorName = "LeftAnkle";
		limits = RagdollLimit.ANKLE_LIMITS;
	};

	{
		part0Name = "LowerTorso";
		part1Name = "RightUpperLeg";
		attachmentName = "RightHipRigAttachment";
		motorParentName = "RightUpperLeg";
		motorName = "RightHip";
		limits = RagdollLimit.HIP_LIMITS;
	};
	{
		part0Name = "RightUpperLeg";
		part1Name = "RightLowerLeg";
		attachmentName = "RightKneeRigAttachment";
		motorParentName = "RightLowerLeg";
		motorName = "RightKnee";
		limits = RagdollLimit.KNEE_LIMITS;
	};
	{
		part0Name = "RightLowerLeg";
		part1Name = "RightFoot";
		attachmentName = "RightAnkleRigAttachment";
		motorParentName = "RightFoot";
		motorName = "RightAnkle";
		limits = RagdollLimit.ANKLE_LIMITS;
	};
}

return RagdollLimit