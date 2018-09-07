package edu.pk.dev.java.util;

import java.math.BigInteger;

/**
 * Created by IntelliJ IDEA.
 * User: prajena
 * Date: 9/7/18
 * Time: 4:20 PM
 * To change this template use File | Settings | File and Code Templates.
 */
public class ProductManagerTest {
	
	public static void main(String[] args) {
		ProductManager productManager = new ProductManager();
		
		// This condition is simply to represent that productId may be null
		BigInteger productId = (args.length == 2 ? new BigInteger(args[0]) : null);
		
		Double amount = productManager.filterProductByIdAndType(productId, 'C').getAmount();
		System.out.println("Amount  = " + amount);
		
		
		
	}
	
}