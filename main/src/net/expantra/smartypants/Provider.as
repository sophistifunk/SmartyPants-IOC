package net.expantra.smartypants
{

    public interface Provider
    {
        /**
         * Returns an instance of the required class. 
         * @return 
         */
        function getInstance():*;
    }
}