READER_DEFAULT_ID=1
# In the docu, often 3 is used. But this doesn't allow creation of a CSR
#READER_DEFAULT_ID=3
READER_DEFAULT_AUTH_ID=2
READER_SO_AUTH_ID=3
READER_SUPPORT_ERASE=openpgp
READER_PIN_METHOD=change
READER_PIN_MIN=6
READER_PIN_MAX=64
READER_SOPIN_MIN=8
READER_SOPIN_MAX=64
DEFAULT_PIN=123456
DEFAULT_SOPIN=12345678
CERT_GENERATION="onhost"
READER_CERT_TARGET=(2 3)
CARD_PUSH_SIGN_ERROR["Failed to store private key: Invalid arguments"]=ignore
CARD_PUSH_SIGN_ERROR["Failed to store private key: Non unique object ID"]=retry
CARD_PUSH_SIGN_ERROR["Failed to store private key: Not supported"]=ignore
