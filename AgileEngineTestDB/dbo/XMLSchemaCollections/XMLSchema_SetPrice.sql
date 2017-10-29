CREATE XML SCHEMA COLLECTION [dbo].[XMLSchema_SetPrice]
    AS N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <xsd:element name="ProductPrices">
    <xsd:complexType>
      <xsd:complexContent>
        <xsd:restriction base="xsd:anyType">
          <xsd:sequence>
            <xsd:element name="ProductPrice" type="ProductPrice" maxOccurs="unbounded" />
          </xsd:sequence>
        </xsd:restriction>
      </xsd:complexContent>
    </xsd:complexType>
  </xsd:element>
  <xsd:complexType name="ProductPrice">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence />
        <xsd:attribute name="ProductId" type="xsd:int" />
        <xsd:attribute name="StoreIDs" type="varchar8000" />
        <xsd:attribute name="Price" type="Decimal2" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:simpleType name="Decimal2">
    <xsd:restriction base="xsd:decimal">
      <xsd:fractionDigits value="2" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="varchar8000">
    <xsd:restriction base="xsd:string">
      <xsd:maxLength value="8000" />
    </xsd:restriction>
  </xsd:simpleType>
</xsd:schema>';

