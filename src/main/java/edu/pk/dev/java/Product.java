package edu.pk.dev.java;

import java.math.BigInteger;

/**
 * Created by IntelliJ IDEA.
 * User: prajena
 * Date: 9/7/18
 * Time: 4:12 PM
 * To change this template use File | Settings | File and Code Templates.
 */
public class Product {
	private BigInteger id;
	private String description;
	private Double amount;
	private Character type;
	
	public BigInteger getId() {
		return id;
	}
	
	public void setId(BigInteger id) {
		this.id = id;
	}
	
	public String getDescription() {
		return description;
	}
	
	public void setDescription(String description) {
		this.description = description;
	}
	
	public Double getAmount() {
		return amount;
	}
	
	public void setAmount(Double amount) {
		this.amount = amount;
	}
	
	public Character getType() {
		return type;
	}
	
	public void setType(Character type) {
		this.type = type;
	}
}
