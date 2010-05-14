int sq(int x)
{
	return log2(x * x + x * x);
}

__kernel void Simple(__global float* a, __global int iNumElements) 
{
	int iGID = get_global_id(0);
	if (iGID >= iNumElements)
	{
		return;
	}
	a[iGID] = sq(iGID);
}