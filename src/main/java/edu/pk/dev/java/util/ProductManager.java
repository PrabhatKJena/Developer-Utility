package edu.pk.dev.java.util;

import edu.pk.dev.java.Product;

import javax.annotation.Nonnull;
import javax.annotation.Nullable;
import java.math.BigInteger;
import java.util.Collections;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: prajena
 * Date: 9/7/18
 * Time: 4:11 PM
 * To change this template use File | Settings | File and Code Templates.
 */
public class ProductManager {
	
	private List<Product> productList = Collections.EMPTY_LIST;
	
	/**
	 * This method filters product from the productList by supplied productId and type and return the same. If no match found then returns null.
	 *
	 * @param productId
	 * @param type
	 * @return Product if found the match by productId and type else returns null
	 */
	public @Nullable Product filterProductByIdAndType(@Nonnull BigInteger productId, @Nonnull Character type) {
		Product product = null;
		for (Product eachProduct : productList) {
			if (productId.equals(eachProduct.getId()) && type.equals(eachProduct.getType())) {
				product = eachProduct;
				break;
			}
		}
		return product;
	}
}
