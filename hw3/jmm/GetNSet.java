import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSet implements State{
	private AtomicIntegerArray value;
	private byte maxval;

	private void create(byte[] v){
		int tmp[] = new int[v.length];
		for(int i=0;i<tmp.length;i++)
		{
			tmp[i] = v[i];
		}
		value = new AtomicIntegerArray(tmp);
	}

	GetNSet(byte[] v){
		maxval = 127;
		create(v);
	}

	GetNSet(byte[] v, byte m){
		maxval = m;
		create(v);
	}

	public int size(){
		return value.length();
	}

    public byte[] current(){
		byte tmp[] = new byte[value.length()];
		for(int i=0;i<tmp.length;i++)
		{
			tmp[i] = (byte) value.get(i);
		}

		return tmp;
	}

	public boolean swap(int i, int j){
	    int tmp1 = value.get(i);
	    int tmp2 = value.get(j);
	    if (value.get(i) <= 0 || value.get(j) >= maxval) 
		{
			return false;
		}
	        value.set(i,tmp1-1);
		value.set(j,tmp2+1);
		return true;
	}

}
