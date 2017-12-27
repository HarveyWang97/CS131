public class Example1{
	public static void main(String[] args){
		System.out.println("hello");
	}
}

// javac practice.java    compile the program and generate a bytcode file
// java Example1     produce output


// sum all integers from 1 to 10, print the result
public class Example2{
	public static void main(String[] args){
		int sum = 0;
		for(int i=1; i<=10; i++)
			sum+=i;
		System.out.println(sum);
	}
}

public class Example3{
	public static void main(String[] args){
		int[] a = {1,2,3,4,5};
		int[] b = {2,4,5,3,2};
		int[] prodict = new int[a.length];

		for(int i=0; i<a.length; i++){
			product[i] = a[i]*b[i];
		}

		
	}
}