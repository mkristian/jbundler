import 'org.junit.runner.JUnitCore'
import 'test.AppTest'

java.lang.System.set_property( 'WORLD', 'world' )
JUnitCore.run_classes( AppTest.java_class )
