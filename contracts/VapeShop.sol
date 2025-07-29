// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VapeShop {
    address public owner;

    struct Product {
        string name;
        uint256 price; // in wei
        uint256 stock;
    }

    Product[] public products;

    event ProductAdded(uint256 productId, string name, uint256 price, uint256 stock);
    event ProductPurchased(address buyer, uint256 productId, uint256 quantity);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Add a new vape product
    function addProduct(string calldata _name, uint256 _price, uint256 _stock) external onlyOwner {
        products.push(Product(_name, _price, _stock));
        emit ProductAdded(products.length - 1, _name, _price, _stock);
    }

    // Get total number of products
    function getProductCount() external view returns (uint256) {
        return products.length;
    }

    // Buy a product
    function buyProduct(uint256 _productId, uint256 _quantity) external payable {
        require(_productId < products.length, "Invalid product");
        Product storage product = products[_productId];
        require(product.stock >= _quantity, "Not enough stock");
        require(msg.value >= product.price * _quantity, "Not enough ETH sent");

        product.stock -= _quantity;

        // Transfer funds to shop owner
        payable(owner).transfer(msg.value);

        emit ProductPurchased(msg.sender, _productId, _quantity);
    }

    // Get details of a product
    function getProduct(uint256 _productId)
        external
        view
        returns (string memory, uint256, uint256)
    {
        require(_productId < products.length, "Invalid product");
        Product memory p = products[_productId];
        return (p.name, p.price, p.stock);
    }
}
