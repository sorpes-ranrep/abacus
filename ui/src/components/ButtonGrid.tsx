import styled from "styled-components";

export const ButtonGrid = styled.div`
    display: grid;
    grid-column-gap: 10px;
    grid-row-gap: 10px;
    grid-template-columns:  repeat(4, minmax(20px, 1fr));
    grid-template-rows: repeat(5, minmax(20px, 1fr));
    padding: 12px;
    justify-items: center;

    width: 80%;
    height: auto;
    margin: auto;
`;
