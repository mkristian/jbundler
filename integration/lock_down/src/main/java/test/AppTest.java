package test;

import static org.junit.Assert.*;

import org.junit.Test;

/**
 * Unit test for simple App.
 */
public class AppTest 
{
    
    @Test
    public void testApp()
    {
	System.out.println( new Foo().toString() );
        assertEquals( System.getProperty( "WORLD" ), "world" );
	System.out.print( "hello " + System.getProperty( "WORLD" ) );
    }
}
